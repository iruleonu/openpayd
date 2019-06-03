//
//  ITunesTrackItemDetailsViewModel.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 02/06/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import enum Result.Result
import enum Result.NoError

final class ITunesTrackItemDetailsViewModelImpl: ITunesItemDetailsViewModel, ITunesItemDetailsViewModelInputs, ITunesItemDetailsViewModelOutputs {
    private let routing: ITunesItemDetailsRouting
    private let itemId: Int
    private let tracksDataProvider: DataProvider<[Track]>
    private let action: (ITunesSearchListAction) -> Void
    
    private let vmState: Atomic<(ITunesItemDetailsViewModelState.VMState, ITunesItemDetailsViewModelState.VMSharedState)>
    private let fetchedTrackProperty: MutableProperty<Track?>
    private var disposables = CompositeDisposable()
    
    var inputs: ITunesItemDetailsViewModelInputs { return self }
    private let viewDidLoadProperty: MutableProperty<Void>
    private let fetchStuffProperty: MutableProperty<DataProviderFetchType>
    
    var outputs: ITunesItemDetailsViewModelOutputs { return self }
    var fetchedStuff: Signal<Result<FetchedStuffTuple, ITunesItemDetailsViewModelError>, NoError>
    private let fetchedStuffObserver: Signal<Result<FetchedStuffTuple, ITunesItemDetailsViewModelError>, NoError>.Observer
    var dataSourceChanges: Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>
    private let dataSourceChangesObserver: Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>.Observer
    
    let fetchTrackAction: Action<(Int, DataProviderFetchType), ([Track], DataProviderSource, DataProviderFetchType), DataProviderError>
    
    init(routing r: ITunesItemDetailsRouting, trackId id: Int, tracksDataProvider tdp: DataProvider<[Track]>, action a: @escaping (ITunesSearchListAction) -> Void) {
        routing = r
        itemId = id
        tracksDataProvider = tdp
        action = a
        vmState = Atomic((ITunesItemDetailsViewModelState.VMState.empty, ITunesItemDetailsViewModelState.VMSharedState.empty))
        fetchedTrackProperty = MutableProperty(nil)
        
        viewDidLoadProperty = MutableProperty(())
        fetchStuffProperty = MutableProperty(DataProviderFetchType.config)
        
        (fetchedStuff, fetchedStuffObserver) = Signal<Result<FetchedStuffTuple, ITunesItemDetailsViewModelError>, NoError>.pipe()
        (dataSourceChanges, dataSourceChangesObserver) = Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>.pipe()
        
        fetchTrackAction = Action { ITunesTrackItemDetailsViewModelImpl.fetchTrackHandler(trackId: $0.0, fetchType: $0.1, tracksDataProvider: tdp) }
        
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
            
            if !strongSelf.fetchTrackAction.isExecuting.value {
                strongSelf.disposables += strongSelf.fetchTrackAction.apply((strongSelf.itemId, fetchType)).start()
            }
        }
        disposables += fetchTrackAction.values.observeValues { [weak self] value in
            self?.tracksDPHandler(result: Result.success(value))
        }
        disposables += fetchTrackAction.errors.observeValues({ [weak self] (error) in
            self?.tracksDPHandler(result: Result.failure(error))
        })
        
        let fetchedItem = fetchedTrackProperty.signal.map(value: ())
        disposables += Signal.zip([fetchedItem])
            .observe(on: QueueScheduler())
            .observeValues { [weak self] _ in
                guard let strongSelf = self else { return }
                let vmState = strongSelf.vmState.value
                let track = vmState.0.track
                let fetchedStuffTuple: FetchedStuffTuple = (nil, track)
                
                guard track != nil else {
                    strongSelf.fetchedStuffObserver.send(value: Result.failure(ITunesItemDetailsViewModelError.noData))
                    return
                }
                
                strongSelf.fetchedStuffObserver.send(value: Result.success(fetchedStuffTuple))
                strongSelf.action(.markTrackHasSeen)
        }
    }
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
    }
    
    func viewDidAppear() {
        // Do nothing
    }
    func userDidTapDeleteButton(sourceVC: UIViewController) {
        let alertController = UIAlertController(title: "Are you sure you want to delete this item?", message: "You wont see it on the list anymore", preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "No", style: .default, handler: nil)
        let destructiveAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.disposables += strongSelf.removeTrackData(trackId: strongSelf.itemId)
            strongSelf.action(.deleteTrack)
            strongSelf.routing.dismissScreen()
        }
        alertController.addAction(otherAction)
        alertController.addAction(destructiveAction)
        sourceVC.present(alertController, animated: true, completion: nil)
    }
    
    private static func fetchTrackHandler(trackId: Int, fetchType: DataProviderFetchType, tracksDataProvider adp: DataProvider<[Track]>) -> SignalProducer<([Track], DataProviderSource, DataProviderFetchType), DataProviderError> {
        return SignalProducer({ (observer, _) in
            adp.fetchStuff(resource: .track(id: "\(trackId)"), explicitFetchType: fetchType).startWithResult({ (result) in
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
    
    private func tracksDPHandler(result: Result<([Track], DataProviderSource, DataProviderFetchType), DataProviderError>) {
        switch result {
        case .success(let (tracks, _, _)):
            guard var track = tracks.first else { return }
            track.userHasSeenThis = true
            
            vmState.modify({ vmState in
                var state = vmState.0
                
                let stateAction = ITunesItemDetailsViewModelState.StateAction.insertTrack(track)
                state = ITunesItemDetailsViewModelState.handleStateAction(stateAction, state: state)
                
                vmState.0 = state
            })
            
            disposables += markTracksHasSeen([track])
            fetchedTrackProperty.value = track
        case .failure(let error):
            print(error.errorDescription)
            fetchedTrackProperty.value = nil
        }
    }
}

// MARK: Persistence related
extension ITunesTrackItemDetailsViewModelImpl {
    private func removeTrackData(trackId: Int) -> Disposable {
        let aux = CompositeDisposable()
        let tracksDP = self.tracksDataProvider
        
        aux += tracksDP
            .fetchData((Resource.track(id: "\(itemId)"), DataProviderFetchType.local))
            .flatMap(.latest) { ITunesTrackItemDetailsViewModelImpl.markTracksHasDeleted($0.0, tracksDataProvider: tracksDP) }
            .start()
        
        return aux
    }
    
    private func markTracksHasSeen(_ tracks: [Track]) -> Disposable? {
        guard tracks.count > 0 else { return nil }
        
        var aux: [Track] = []
        
        tracks.forEach { (track) in
            var t = track
            t.userHasSeenThis = true
            aux.append(t)
        }
        
        return tracksDataProvider.saveToPersistence(aux).start()
    }
    
    private static func markTracksHasDeleted(_ tracks: [Track], tracksDataProvider: DataProvider<[Track]>) -> SignalProducer<[Track], DataProviderError> {
        guard tracks.count > 0 else { return SignalProducer(value: []) }
        
        var aux: [Track] = []
        
        tracks.forEach { (track) in
            var t = track
            t.userHasDeletedThis = true
            aux.append(t)
        }
        
        return tracksDataProvider.saveToPersistence(aux)
    }
}

extension ITunesTrackItemDetailsViewModelImpl: ITunesItemDetailsHeaderDetails {
    var itemTitle: String {
        return vmState.value.0.track?.trackName ?? ""
    }
    
    var itemSubtitle: String {
        return vmState.value.0.track?.trackDescription ?? ""
    }
    
    var itemDescription: String {
        return ""
    }
    
    var itemImageUrl: String {
        return vmState.value.0.track?.artworkUrl100 ?? ""
    }
}

extension ITunesTrackItemDetailsViewModelImpl: ITunesItemDetailsItemSpecific {
    var screenTitle: String {
        return "Track details"
    }
}
