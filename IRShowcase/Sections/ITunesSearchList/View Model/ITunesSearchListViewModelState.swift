//
//  ITunesSearchListViewModelState.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

final class ITunesSearchListViewModelState {
    struct VMState {
        static let empty = VMState()
    }
    
    struct VMSharedState {
        struct DataSource {
            var rows: [ITunesSearchListCellViewModel]
            static let empty = DataSource(rows: [])
        }
        
        var dataSource: DataSource
        static let empty = VMSharedState(dataSource: .empty)
    }
    
    enum StateAction {
        // No actions
    }
    
    enum SharedStateAction {
        case replacePosts([SearchResultsWrapperModelTypeProtocol])
        case updatePosts([SearchResultsWrapperModelTypeProtocol])
        case updateOrInsertIfMissing([SearchResultsWrapperModelTypeProtocol])
        case reset
    }
    
    enum HybridAction {
        // No actions
    }
    
    static func handleStateAction(_ action: StateAction, state: VMState) -> VMState {
        return state
    }
    
    static func handleSharedStateAction(_ action: SharedStateAction, sharedState: VMSharedState) -> VMSharedState {
        var sharedState = sharedState
        
        switch action {
        case let .replacePosts(items):
            sharedState = replaceItems(items, sharedState: sharedState)
        case let .updatePosts(items):
            sharedState = updateItems(items, sharedState: sharedState)
        case let .updateOrInsertIfMissing(items):
            sharedState = updateOrInsertIfMissing(items, sharedState: sharedState)
        case .reset:
            sharedState = .empty
        }
        
        return sharedState
    }
    
    static func handleHybridStateAction(_ action: HybridAction, state: VMState, sharedState: VMSharedState) -> (VMState, VMSharedState) {
        return (state, sharedState)
    }
    
    private static func replaceItems(_ items: [SearchResultsWrapperModelTypeProtocol], sharedState: VMSharedState) -> VMSharedState {
        var sharedState: VMSharedState = sharedState
        
        var aux: [ITunesSearchListCellViewModel] = []
        
        items.forEach { (item) in
            switch item.wrapperType {
            case .audiobook:
                guard let cast = item as? AudioBook else { break }
                let cellVM = ITunesSearchListCellViewModel(id: cast.wrapperIdentifier, title: cast.collectionName, imageUrl: cast.artworkUrl60, cellType: .audioBook, userHasSeenItem: false)
                aux.append(cellVM)
            case .track:
                guard let cast = item as? Track else { break }
                let cellVM = ITunesSearchListCellViewModel(id: cast.wrapperIdentifier, title: cast.trackName, imageUrl: cast.artworkUrl60, cellType: .track, userHasSeenItem: false)
                aux.append(cellVM)
            default:
                break
            }
        }
        
        sharedState.dataSource.rows = aux
        
        return sharedState
    }
    
    private static func updateItems(_ items: [SearchResultsWrapperModelTypeProtocol], sharedState: VMSharedState) -> VMSharedState {
        var sharedState: VMSharedState = sharedState
        
        var aux: [ITunesSearchListCellViewModel] = sharedState.dataSource.rows
        
        items.forEach { item in
            switch item.wrapperType {
            case .audiobook:
                guard let cast = item as? AudioBook else { break }
                guard let indexForElementWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == item.wrapperIdentifier }) else { break }
                let updatedCellVM = ITunesSearchListCellViewModel(id: cast.wrapperIdentifier, title: cast.collectionName, imageUrl: cast.artworkUrl60, cellType: .audioBook, userHasSeenItem: cast.userHasSeenThis)
                aux.remove(at: indexForElementWithSameId)
                aux.insert(updatedCellVM, at: indexForElementWithSameId)
            case .track:
                guard let cast = item as? Track else { break }
                guard let indexForElementWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == item.wrapperIdentifier }) else { break }
                let updatedCellVM = ITunesSearchListCellViewModel(id: cast.wrapperIdentifier, title: cast.trackName, imageUrl: cast.artworkUrl60, cellType: .track, userHasSeenItem: cast.userHasSeenThis)
                aux.remove(at: indexForElementWithSameId)
                aux.insert(updatedCellVM, at: indexForElementWithSameId)
            default:
                break
            }
        }
        
        sharedState.dataSource.rows = aux
        
        return sharedState
    }
    
    private static func updateOrInsertIfMissing(_ items: [SearchResultsWrapperModelTypeProtocol], sharedState: VMSharedState) -> VMSharedState {
        var sharedState: VMSharedState = sharedState
        
        var aux: [ITunesSearchListCellViewModel] = sharedState.dataSource.rows
        
        items.forEach { (item) in
            switch item.wrapperType {
            case .audiobook:
                guard let cast = item as? AudioBook else { break }
                let updatedCellVM = ITunesSearchListCellViewModel(id: cast.wrapperIdentifier, title: cast.collectionName, imageUrl: cast.artworkUrl60, cellType: .audioBook, userHasSeenItem: cast.userHasSeenThis)
                guard let indexForElementWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == item.wrapperIdentifier }) else {
                    aux.insert(updatedCellVM, at: 0)
                    break
                }
                aux.remove(at: indexForElementWithSameId)
                aux.insert(updatedCellVM, at: indexForElementWithSameId)
            case .track:
                guard let cast = item as? Track else { break }
                let updatedCellVM = ITunesSearchListCellViewModel(id: cast.wrapperIdentifier, title: cast.trackName, imageUrl: cast.artworkUrl60, cellType: .track, userHasSeenItem: cast.userHasSeenThis)
                guard let indexForElementWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == item.wrapperIdentifier }) else {
                    aux.insert(updatedCellVM, at: 0)
                    break
                }
                aux.remove(at: indexForElementWithSameId)
                aux.insert(updatedCellVM, at: indexForElementWithSameId)
            default:
                break
            }
        }
        
        sharedState.dataSource.rows = aux
        
        return sharedState
    }
}
