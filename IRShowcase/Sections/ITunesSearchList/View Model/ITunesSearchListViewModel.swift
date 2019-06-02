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

typealias ITunesSearchListViewModelPersistenceFetcher = EntityFetchAudiobooksProtocol & EntityFetchTracksProtocol

final class ITunesSearchListViewModelImpl: ITunesSearchListViewModel, ITunesSearchListViewModelInputs, ITunesSearchListViewModelOutputs {
    private let routing: ITunesSearchListRouting
    private let persistenceSaver: DataProvider<SearchItemResponse>
    private let persistenceFetcher: ITunesSearchListViewModelPersistenceFetcher
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
    
    init(routing r: ITunesSearchListRouting, persistenceFetcher pf: ITunesSearchListViewModelPersistenceFetcher, persistenceSaver ps: DataProvider<SearchItemResponse>, remoteDataProvider rdp: DataProvider<SearchItemResponse>, connectivity c: ConnectivityService) {
        routing = r
        persistenceSaver = ps
        persistenceFetcher = pf
        remoteDataProvider = rdp
        vmState = Atomic((ITunesSearchListViewModelState.VMState.empty, ITunesSearchListViewModelState.VMSharedState.empty))
        connectivity = c
        
        viewDidLoadProperty = MutableProperty(())
        fetchStuffProperty = MutableProperty(Resource.unknown)
        
        (fetchedStuff, fetchedStuffObserver) = Signal<Result<[SearchResultsWrapperModelTypeProtocol], ITunesSearchListViewModelError>, NoError>.pipe()
        (dataSourceChanges, dataSourceChangesObserver) = Signal<ITunesSearchListViewModelState.VMSharedState.DataSource, NoError>.pipe()
        
        fetchStuffAction = Action { ITunesSearchListViewModelImpl.fetchStuffHandler($0, remoteDataProvider: rdp) }
        
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
            self?.itemsDPHandler(result: Result.success(value))
        }
        disposables += fetchStuffAction.errors.observeValues({ [weak self] (error) in
            self?.itemsDPHandler(result: Result.failure(error))
        })
    }
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
    }
    
    func fetchStuff() {
        fetchStuffProperty.value = .items(query: "test", limit: 100)
    }
    
    func userDidTapAudioBookCellWithAudioBookId(_ id: Int64) {
        routing.showAudioBook(id: id) { [weak self] (action) in
            switch action {
            case .markAudioBookHasSeen:
                self?.markItemAsSeen(id, wrapperType: .audiobook)
            case .deleteAudioBook:
                self?.markItemAsDeleted(id, wrapperType: .audiobook)
            default:
                break
            }
        }
    }
    
    func userDidTapTrackCellWithTrackId(_ id: Int64) {
        routing.showTrack(id: id) { [weak self] (action) in
            switch action {
            case .markTrackHasSeen:
                self?.markItemAsSeen(id, wrapperType: .track)
            case .deleteTrack:
                self?.markItemAsDeleted(id, wrapperType: .track)
            default:
                break
            }
        }
    }
    
    private func markItemAsSeen(_ id: Int64, wrapperType: SearchResultsWrapperType) {
        vmState.modify({ vmState in
            var sharedState = vmState.1
            
            let sharedStateAction = ITunesSearchListViewModelState.SharedStateAction.markRowAsSeen(id, wrapperType)
            sharedState = ITunesSearchListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
            
            vmState.1 = sharedState
        })
        dataSourceChangesObserver.send(value: vmState.value.1.dataSource)
    }
    
    private func markItemAsDeleted(_ id: Int64, wrapperType: SearchResultsWrapperType) {
        vmState.modify({ vmState in
            var sharedState = vmState.1
            
            let sharedStateAction = ITunesSearchListViewModelState.SharedStateAction.markRowAsDeleted(id, wrapperType)
            sharedState = ITunesSearchListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
            
            vmState.1 = sharedState
        })
        dataSourceChangesObserver.send(value: vmState.value.1.dataSource)
    }
    
    func triggerRefreshControl() {
        fetchStuff()
    }
    
    private static func fetchStuffHandler(_ resource: Resource, remoteDataProvider rdp: DataProvider<SearchItemResponse>) -> SignalProducer<[(SearchItemResponse, DataProviderSource)], DataProviderError> {
        return SignalProducer({ (observer, _) in
            let remoteFetch = rdp.fetchStuff(resource: resource)
                .flatMapError({ _ -> SignalProducer<(SearchItemResponse, DataProviderSource), DataProviderError> in
                    return SignalProducer({ (observer, _) in
                        observer.send(value: (SearchItemResponse(), .remote))
                    })
            })
            remoteFetch.startWithResult({ (result) in
                switch result {
                case .success(let remoteValue):
                    guard remoteValue.0.results.count > 0 else {
                        let error = NSError.error(withMessage: "No data")
                        observer.send(error: DataProviderError.requestError(error: error))
                        return
                    }
                    
                    observer.send(value: [remoteValue])
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            })
        })
    }
    
    private func itemsDPHandler(result: Result<[(SearchItemResponse, DataProviderSource)], DataProviderError>) {
        switch result {
        case .success(let value):
            disposables += fetchLocalAndMergeWithRemoteItems(value, persistenceFetcher: persistenceFetcher).startWithValues { [weak self] (mergedItems) in
                guard let strongSelf = self else { return }
                strongSelf.disposables += strongSelf.persistItems(mergedItems)
                
                strongSelf.vmState.modify({ vmState in
                    var sharedState = vmState.1
                    
                    let sharedStateAction = ITunesSearchListViewModelState.SharedStateAction.replaceItems((mergedItems))
                    sharedState = ITunesSearchListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                    
                    vmState.1 = sharedState
                })
                
                strongSelf.fetchedStuffObserver.send(value: Result.success((mergedItems)))
                strongSelf.dataSourceChangesObserver.send(value: strongSelf.vmState.value.1.dataSource)
            }
        case .failure:
            fetchedStuffObserver.send(value: Result.failure(ITunesSearchListViewModelError.noData))
        }
    }
}

// MARK: Persistence methods
extension ITunesSearchListViewModelImpl {
    //swiftlint:disable function_body_length
    private func fetchLocalAndMergeWithRemoteItems(_ items: [(SearchItemResponse, DataProviderSource)], persistenceFetcher: ITunesSearchListViewModelPersistenceFetcher) -> SignalProducer<[SearchResultsWrapperModelTypeProtocol], NoError> {
        return SignalProducer({ (observer, _) in
            let remoteItems = items.first(where: { $0.1 == .remote })?.0.results
            let audiobooks = remoteItems?.filter({ $0.wrapperType == .audiobook }) ?? []
            let tracks = remoteItems?.filter({ $0.wrapperType == .track }) ?? []
            
            let fetchAudioBooks: SignalProducer<SearchItemResponse, PersistenceLayerError> = persistenceFetcher
                .fetchAudiobooks(ids: audiobooks.compactMap({ $0.wrapperIdentifier }))
                .map({ SearchItemResponse(resultCount: $0.count, results: $0) })
                .flatMapError { _ in SignalProducer(value: SearchItemResponse(resultCount: 0, results: [])) }
            let fetchTracks: SignalProducer<SearchItemResponse, PersistenceLayerError> = persistenceFetcher
                .fetchTracks(ids: tracks.compactMap({ $0.wrapperIdentifier }))
                .map({ SearchItemResponse(resultCount: $0.count, results: $0) })
                .flatMapError { _ in SignalProducer(value: SearchItemResponse(resultCount: 0, results: [])) }
            
            // Fetch local items. If found replace remote:
            // Replace userHasSeenThis and userHasDeletedThis flags
            var aux: [SearchResultsWrapperModelTypeProtocol] = items.compactMap({ $0.0.results }).flatMap({ $0 })
            SignalProducer.zip([fetchAudioBooks, fetchTracks]).startWithResult({ (result) in
                switch result {
                case .failure:
                    observer.send(value: aux)
                    observer.sendCompleted()
                case .success(let arrays):
                    arrays.forEach({ (array) in
                        array.results.forEach({ (wrapper) in
                            switch wrapper.wrapperType {
                            case .audiobook:
                                guard let cast = wrapper as? AudioBook else { break }
                                guard let index = aux.firstIndex(where: { $0.wrapperIdentifier == wrapper.wrapperIdentifier }) else { break }
                                guard var remoteCast = audiobooks.first(where: { $0.wrapperIdentifier == wrapper.wrapperIdentifier }) as? AudioBook else { break }
                                remoteCast.userHasSeenThis = cast.userHasSeenThis
                                remoteCast.userHasDeletedThis = cast.userHasDeletedThis
                                aux.remove(at: index)
                                aux.insert(remoteCast, at: index)
                            case .track:
                                guard let cast = wrapper as? Track else { break }
                                guard let index = aux.firstIndex(where: { $0.wrapperIdentifier == wrapper.wrapperIdentifier }) else { break }
                                guard var remoteCast = tracks.first(where: { $0.wrapperIdentifier == wrapper.wrapperIdentifier }) as? Track else { break }
                                remoteCast.userHasSeenThis = cast.userHasSeenThis
                                remoteCast.userHasDeletedThis = cast.userHasDeletedThis
                                aux.remove(at: index)
                                aux.insert(remoteCast, at: index)
                            default:
                                break
                            }
                        })
                    })
                    observer.send(value: aux)
                    observer.sendCompleted()
                }
            })
        })
    }
    //swiftlint:enable function_body_length
    
    private func persistItems(_ items: [SearchResultsWrapperModelTypeProtocol]) -> Disposable? {
        guard items.count > 0 else { return nil }
        return persistenceSaver
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
