//
//  ITunesSearchListViewModel.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.Result
import enum Result.NoError
import Connectivity

enum ITunesSearchListViewModelError: Error {
    case unknown
    case noData
    case noConnection
    
    var errorDescription: String {
        switch self {
        case .noData:
            return "Couldnt fetch any data"
        default:
            return "Unknown error"
        }
    }
}

protocol ITunesSearchListViewModelInputs {
    func viewDidLoad()
    func fetchStuff()
    func userDidTapAudioBookCellWithAudioBookId(_ id: Int64)
    func userDidTapTrackCellWithTrackId(_ id: Int64)
    func triggerRefreshControl()
}

protocol ITunesSearchListViewModelOutputs {
    var fetchedStuff: Signal<Result<[SearchResultsWrapperModelTypeProtocol], ITunesSearchListViewModelError>, NoError> { get }
    var dataSourceChanges: Signal<ITunesSearchListViewModelState.VMSharedState.DataSource, NoError> { get }
}

protocol ITunesSearchListViewModel: ITunesSearchListCollectionNodeDataSourceProtocol {
    var inputs: ITunesSearchListViewModelInputs { get }
    var outputs: ITunesSearchListViewModelOutputs { get }
}

final class ITunesSearchListViewModelImpl: ITunesSearchListViewModel, ITunesSearchListViewModelInputs, ITunesSearchListViewModelOutputs {
    private let routing: PostsListRouting
    private let localDataProvider: DataProvider<SearchItemResponse>
    private let remoteDataProvider: DataProvider<SearchItemResponse>
    private let vmState: Atomic<(ITunesSearchListViewModelState.VMState, ITunesSearchListViewModelState.VMSharedState)>
    private let connectivity: ConnectivityService
    private var disposables = CompositeDisposable()
    
    var inputs: ITunesSearchListViewModelInputs { return self }
    private let viewDidLoadProperty: MutableProperty<Void>
    private let fetchStuffProperty: MutableProperty<Resource>
    
    var outputs: ITunesSearchListViewModelOutputs { return self }
    var fetchedStuff: Signal<Result<[SearchResultsWrapperModelTypeProtocol], ITunesSearchListViewModelError>, NoError>
    private var fetchedStuffObserver: Signal<Result<[SearchResultsWrapperModelTypeProtocol], ITunesSearchListViewModelError>, NoError>.Observer
    var dataSourceChanges: Signal<ITunesSearchListViewModelState.VMSharedState.DataSource, NoError>
    private let dataSourceChangesObserver: Signal<ITunesSearchListViewModelState.VMSharedState.DataSource, NoError>.Observer

    let fetchStuffAction: Action<Resource, [(SearchItemResponse, DataProviderSource)], DataProviderError>
    
    deinit {
        disposables.dispose()
    }
    
    init(routing r: PostsListRouting, localDataProvider ldp: DataProvider<SearchItemResponse>, remoteDataProvider rdp: DataProvider<SearchItemResponse>, connectivity c: ConnectivityService) {
        routing = r
        localDataProvider = ldp
        remoteDataProvider = rdp
        vmState = Atomic((ITunesSearchListViewModelState.VMState.empty, ITunesSearchListViewModelState.VMSharedState.empty))
        connectivity = c
        
        viewDidLoadProperty = MutableProperty(())
        fetchStuffProperty = MutableProperty(Resource.unknown)
        
        (fetchedStuff, fetchedStuffObserver) = Signal<Result<[SearchResultsWrapperModelTypeProtocol], ITunesSearchListViewModelError>, NoError>.pipe()
        (dataSourceChanges, dataSourceChangesObserver) = Signal<ITunesSearchListViewModelState.VMSharedState.DataSource, NoError>.pipe()
        
        fetchStuffAction = Action { ITunesSearchListViewModelImpl.fetchStuffHandler($0, localDataProvider: ldp, remoteDataProvider: rdp) }
        
        setupBindings()
    }
    
    private func setupBindings() {
        disposables += connectivity.isReachableProperty.signal.skipRepeats().observeValues({ [weak self] (connected) in
            guard connected else { return }
            self?.fetchStuff()
        })
        disposables += viewDidLoadProperty.signal.observeValues { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.disposables += strongSelf.connectivity.performSingleConnectivityCheck().start()
            strongSelf.fetchStuff()
        }
        disposables += fetchStuffProperty.signal.observeValues { [weak self] (resource) in
            guard let strongSelf = self else { return }
            guard !strongSelf.fetchStuffAction.isExecuting.value else { return }
            strongSelf.fetchStuffAction.apply(resource).start()
        }
        disposables += fetchStuffAction.values.observeValues { [weak self] value in
            self?.postsDPHandler(result: Result.success(value))
        }
        disposables += fetchStuffAction.errors.observeValues({ [weak self] (error) in
            self?.postsDPHandler(result: Result.failure(error))
        })
    }
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
    }
    
    func fetchStuff() {
        fetchStuffProperty.value = .items(query: "test", limit: 100)
    }
    
    func userDidTapAudioBookCellWithAudioBookId(_ id: Int64) {
        // TODO: mark cell has seen
        routing.showAudioBook(id: id) { (action) in
            switch action {
            case .deleteAudioBook:
                break
            default:
                break
            }
        }
    }
    
    func userDidTapTrackCellWithTrackId(_ id: Int64) {
        // TODO: mark cell has seen
        routing.showTrack(id: id) { (action) in
            switch action {
            case .deleteTrack:
                break
            default:
                break
            }
        }
    }
    
    func triggerRefreshControl() {
        fetchStuff()
    }
    
    private static func fetchStuffHandler(_ resource: Resource, localDataProvider ldp: DataProvider<SearchItemResponse>, remoteDataProvider rdp: DataProvider<SearchItemResponse>) -> SignalProducer<[(SearchItemResponse, DataProviderSource)], DataProviderError> {
        return SignalProducer({ (observer, _) in
            let localFetch = ldp.fetchStuff(resource: resource)
                .flatMapError({ _ -> SignalProducer<(SearchItemResponse, DataProviderSource), DataProviderError> in
                    return SignalProducer({ (observer, _) in
                        observer.send(value: (SearchItemResponse(), .local))
                    })
            })
            let remoteFetch = rdp.fetchStuff(resource: resource)
                .flatMapError({ _ -> SignalProducer<(SearchItemResponse, DataProviderSource), DataProviderError> in
                    return SignalProducer({ (observer, _) in
                        observer.send(value: (SearchItemResponse(), .remote))
                    })
            })
            localFetch.combineLatest(with: remoteFetch).startWithResult({ (result) in
                switch result {
                case .success(let localValue, let remoteValue):
                    guard localValue.0.results.count > 0 || remoteValue.0.results.count > 0 else {
                        let error = NSError.error(withMessage: "No data")
                        observer.send(error: DataProviderError.requestError(error: error))
                        return
                    }
                    
                    observer.send(value: [localValue, remoteValue])
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            })
        })
    }
    
    private func postsDPHandler(result: Result<[(SearchItemResponse, DataProviderSource)], DataProviderError>) {
        switch result {
        case .success(let value):
            disposables += persistRemoteItems(value.filter({ $0.1 == .remote }).compactMap({ $0.0.results }).flatMap({ $0 }))
            
            let items = mergeLocalAndRemoteItems(value)
            
            vmState.modify({ vmState in
                var sharedState = vmState.1
                
                let sharedStateAction = ITunesSearchListViewModelState.SharedStateAction.replacePosts(items)
                sharedState = ITunesSearchListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                
                vmState.1 = sharedState
            })
            
            fetchedStuffObserver.send(value: Result.success(items))
            dataSourceChangesObserver.send(value: vmState.value.1.dataSource)
        case .failure:
            fetchedStuffObserver.send(value: Result.failure(ITunesSearchListViewModelError.noData))
        }
    }
}

// MARK: Persistence methods
extension ITunesSearchListViewModelImpl {
    private func mergeLocalAndRemoteItems(_ items: [(SearchItemResponse, DataProviderSource)]) -> [SearchResultsWrapperModelTypeProtocol] {
        // Simply give preference to the remote posts
        let nonLocal = items.first(where: { $0.1 == .remote })?.0
        if let nl = nonLocal, nl.results.count > 0 {
            return nl.results
        }
        
        return items.compactMap({ $0.0.results }).flatMap({ $0 })
    }
    
    private func persistRemoteItems(_ items: [SearchResultsWrapperModelTypeProtocol]) -> Disposable? {
        guard items.count > 0 else { return nil }
        return localDataProvider
            .saveToPersistence(SearchItemResponse(resultCount: items.count, results: items))
            .start(on: QueueScheduler.main)
            .start()
    }
}

// MARK: ITunesSearchListCollectionNodeDataSourceProtocol
extension ITunesSearchListViewModelImpl {
    func numberOfSections(dataSource: ITunesSearchListViewModelState.VMSharedState.DataSource) -> Int {
        return 1
    }

    func numberOfRowsInSection(_ section: Int, dataSource: ITunesSearchListViewModelState.VMSharedState.DataSource) -> Int {
        return dataSource.rows.count
    }
}
