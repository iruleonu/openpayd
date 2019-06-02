//
//  ITunesAudioBookItemDetailsViewModel.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 02/06/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.Result
import enum Result.NoError

final class ITunesAudioBookItemDetailsViewModelImpl: ITunesItemDetailsViewModel, ITunesItemDetailsViewModelInputs, ITunesItemDetailsViewModelOutputs {
    private let routing: ITunesItemDetailsRouting
    private let itemId: Int
    private let audioBooksDataProvider: DataProvider<[AudioBook]>
    private let action: (ITunesSearchListAction) -> Void
    
    private let vmState: Atomic<(ITunesItemDetailsViewModelState.VMState, ITunesItemDetailsViewModelState.VMSharedState)>
    private let fetchedAudioBookProperty: MutableProperty<AudioBook?>
    private var disposables = CompositeDisposable()
    
    var inputs: ITunesItemDetailsViewModelInputs { return self }
    private let viewDidLoadProperty: MutableProperty<Void>
    private let fetchStuffProperty: MutableProperty<DataProviderFetchType>
    
    var outputs: ITunesItemDetailsViewModelOutputs { return self }
    var fetchedStuff: Signal<Result<FetchedStuffTuple, ITunesItemDetailsViewModelError>, NoError>
    private let fetchedStuffObserver: Signal<Result<FetchedStuffTuple, ITunesItemDetailsViewModelError>, NoError>.Observer
    var dataSourceChanges: Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>
    private let dataSourceChangesObserver: Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>.Observer
    
    let fetchAudioBookAction: Action<(Int, DataProviderFetchType), ([AudioBook], DataProviderSource, DataProviderFetchType), DataProviderError>
    
    init(routing r: ITunesItemDetailsRouting, audioBookId id: Int, audioBooksDataProvider adp: DataProvider<[AudioBook]>, action a: @escaping (ITunesSearchListAction) -> Void) {
        routing = r
        itemId = id
        audioBooksDataProvider = adp
        action = a
        vmState = Atomic((ITunesItemDetailsViewModelState.VMState.empty, ITunesItemDetailsViewModelState.VMSharedState.empty))
        fetchedAudioBookProperty = MutableProperty(nil)
        
        viewDidLoadProperty = MutableProperty(())
        fetchStuffProperty = MutableProperty(DataProviderFetchType.config)
        
        (fetchedStuff, fetchedStuffObserver) = Signal<Result<FetchedStuffTuple, ITunesItemDetailsViewModelError>, NoError>.pipe()
        (dataSourceChanges, dataSourceChangesObserver) = Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>.pipe()
        
        fetchAudioBookAction = Action { ITunesAudioBookItemDetailsViewModelImpl.fetchAudioBookHandler(audioBookId: $0.0, fetchType: $0.1, audioBookDataProvider: adp) }
        
        setupBindings()
    }
    
    deinit {
        disposables.dispose()
    }
    
    private func setupBindings() {
        disposables += viewDidLoadProperty.signal.observeValues { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.fetchStuffProperty.value = DataProviderFetchType.config
        }
        disposables += fetchStuffProperty.signal.observeValues { [weak self] (fetchType) in
            guard let strongSelf = self else { return }
            
            if !strongSelf.fetchAudioBookAction.isExecuting.value {
                strongSelf.disposables += strongSelf.fetchAudioBookAction.apply((strongSelf.itemId, fetchType)).start()
            }
        }
        disposables += fetchAudioBookAction.values.observeValues { [weak self] value in
            self?.audioBookDPHandler(result: Result.success(value))
        }
        disposables += fetchAudioBookAction.errors.observeValues({ [weak self] (error) in
            self?.audioBookDPHandler(result: Result.failure(error))
        })
        
        let fetchedItem = fetchedAudioBookProperty.signal.map(value: ())
        disposables += Signal.zip([fetchedItem])
            .observe(on: QueueScheduler())
            .observeValues { [weak self] _ in
                guard let strongSelf = self else { return }
                let vmState = strongSelf.vmState.value
                let audioBook = vmState.0.audioBook
                let fetchedStuffTuple: FetchedStuffTuple = (audioBook, nil)
                
                guard audioBook != nil else {
                    strongSelf.fetchedStuffObserver.send(value: Result.failure(ITunesItemDetailsViewModelError.noData))
                    return
                }
                
                strongSelf.fetchedStuffObserver.send(value: Result.success(fetchedStuffTuple))
                strongSelf.action(.markAudioBookHasSeen)
        }
    }
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
    }
    
    func viewDidAppear() {
        // Do nothing
    }
    
    func userDidTapDeleteButton() {
        disposables += removeAudiobook(id: itemId)
        action(.deleteAudioBook)
        routing.dismissScreen()
    }
    
    private static func fetchAudioBookHandler(audioBookId: Int, fetchType: DataProviderFetchType, audioBookDataProvider adp: DataProvider<[AudioBook]>) -> SignalProducer<([AudioBook], DataProviderSource, DataProviderFetchType), DataProviderError> {
        return SignalProducer({ (observer, _) in
            adp.fetchStuff(resource: .audiobook(id: "\(audioBookId)"), explicitFetchType: fetchType).startWithResult({ (result) in
                switch result {
                case .success(let value):
                    let tuple = (value.0, value.1, fetchType)
                    observer.send(value: tuple)
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            })
        })
    }
    
    private func audioBookDPHandler(result: Result<([AudioBook], DataProviderSource, DataProviderFetchType), DataProviderError>) {
        switch result {
        case .success(let (audioBooks, _, _)):
            guard var audioBook = audioBooks.first else { return }
            audioBook.userHasSeenThis = true
            
            vmState.modify({ vmState in
                var state = vmState.0
                
                let stateAction = ITunesItemDetailsViewModelState.StateAction.insertAudiobook(audioBook)
                state = ITunesItemDetailsViewModelState.handleStateAction(stateAction, state: state)
                
                vmState.0 = state
            })
            
            disposables += markAudioBooksHasSeen([audioBook])
            fetchedAudioBookProperty.value = audioBook
        case .failure(let error):
            print(error.errorDescription)
            fetchedAudioBookProperty.value = nil
        }
    }
}

// MARK: Persistence related
extension ITunesAudioBookItemDetailsViewModelImpl {
    private func removeAudiobook(id: Int) -> Disposable {
        let aux = CompositeDisposable()
        let audioBooksDP = self.audioBooksDataProvider
        
        aux += audioBooksDP
            .fetchData((Resource.audiobook(id: "\(id)"), DataProviderFetchType.local))
            .flatMap(.latest) { ITunesAudioBookItemDetailsViewModelImpl.markAudioBookHasDeleted($0.0, dataProvider: audioBooksDP) }
            .start()
        
        return aux
    }
    
    private func markAudioBooksHasSeen(_ audiobooks: [AudioBook]) -> Disposable? {
        guard audiobooks.count > 0 else { return nil }
        
        var aux: [AudioBook] = []
        
        audiobooks.forEach { (track) in
            var t = track
            t.userHasSeenThis = true
            aux.append(t)
        }
        
        return audioBooksDataProvider.saveToPersistence(aux).start()
    }
    
    private static func markAudioBookHasDeleted(_ tracks: [AudioBook], dataProvider: DataProvider<[AudioBook]>) -> SignalProducer<[AudioBook], DataProviderError> {
        guard tracks.count > 0 else { return SignalProducer(value: []) }
        
        var aux: [AudioBook] = []
        
        tracks.forEach { (track) in
            var t = track
            t.userHasDeletedThis = true
            aux.append(t)
        }
        
        return dataProvider.saveToPersistence(aux)
    }
}

extension ITunesAudioBookItemDetailsViewModelImpl: ITunesItemDetailsHeaderDetails {
    var itemTitle: String {
        return vmState.value.0.audioBook?.collectionName ?? ""
    }
    
    var itemSubtitle: String {
        return vmState.value.0.audioBook?.artistName ?? ""
    }
    
    var itemDescription: String {
        return vmState.value.0.audioBook?.itemDescription ?? ""
    }
    
    var itemImageUrl: String {
        return vmState.value.0.audioBook?.artworkUrl100 ?? ""
    }
}

extension ITunesAudioBookItemDetailsViewModelImpl: ITunesItemDetailsItemSpecific {
    var screenTitle: String {
        return "Audiobook details"
    }
}
