//
//  ITunesItemDetailsViewModelState.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 24/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

final class ITunesItemDetailsViewModelState {
    struct VMState {
        var audioBook: AudioBook?
        var track: Track?
        static let empty = VMState(audioBook: nil, track: nil)
    }
    
    struct VMSharedState {
        struct DataSource {
            var rows: [ITunesItemDetailsCellViewModel]
            static let empty = DataSource(rows: [])
        }
        
        var dataSource: DataSource
        static let empty = VMSharedState(dataSource: DataSource.empty)
    }
    
    enum StateAction {
        case insertAudiobook(AudioBook)
        case insertTrack(Track)
    }
    
    enum SharedStateAction {
        // Empty
    }
    
    enum HybridAction {
        // Empty
    }
    
    static func handleStateAction(_ action: StateAction, state: VMState) -> VMState {
        var state = state
        
        switch action {
        case .insertAudiobook(let audioBook):
            state.audioBook = audioBook
        case .insertTrack(let track):
            state.track = track
        }
        
        return state
    }
    
    static func handleSharedStateAction(_ action: SharedStateAction, sharedState: VMSharedState) -> VMSharedState {
        return sharedState
    }
    
    static func handleHybridStateAction(_ action: HybridAction, state: VMState, sharedState: VMSharedState) -> (VMState, VMSharedState) {
        return (state, sharedState)
    }
}
