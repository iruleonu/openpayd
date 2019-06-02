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
        case replaceItems([SearchResultsWrapperModelTypeProtocol])
        case updateItems([SearchResultsWrapperModelTypeProtocol])
        case updateOrInsertIfMissing([SearchResultsWrapperModelTypeProtocol])
        case markRowAsSeen(Int64, SearchResultsWrapperType)
        case markRowAsDeleted(Int64, SearchResultsWrapperType)
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
        case let .markRowAsSeen(itemId, wrapperType):
            sharedState = markRowWithItemIdAsSeen(itemId, wrapperType: wrapperType, sharedState: sharedState)
        case let .markRowAsDeleted(itemId, wrapperType):
            sharedState = markRowWithItemIdAsDeleted(itemId, wrapperType: wrapperType, sharedState: sharedState)
        case let .replaceItems(items):
            sharedState = replaceItems(items, sharedState: sharedState)
        case let .updateItems(items):
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
                guard !cast.userHasDeletedThis else { break }
                let cellVM = ITunesSearchListCellViewModel(id: cast.wrapperIdentifier, title: cast.collectionName, imageUrl: cast.artworkUrl60, cellType: .audioBook, userHasSeenItem: cast.userHasSeenThis)
                aux.append(cellVM)
            case .track:
                guard let cast = item as? Track else { break }
                guard !cast.userHasDeletedThis else { break }
                let cellVM = ITunesSearchListCellViewModel(id: cast.wrapperIdentifier, title: cast.trackName, imageUrl: cast.artworkUrl60, cellType: .track, userHasSeenItem: cast.userHasSeenThis)
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
                
                guard !cast.userHasDeletedThis else {
                    aux.remove(at: indexForElementWithSameId)
                    break
                }
                
                let updatedCellVM = ITunesSearchListCellViewModel(id: cast.wrapperIdentifier, title: cast.collectionName, imageUrl: cast.artworkUrl60, cellType: .audioBook, userHasSeenItem: cast.userHasSeenThis)
                aux.remove(at: indexForElementWithSameId)
                aux.insert(updatedCellVM, at: indexForElementWithSameId)
            case .track:
                guard let cast = item as? Track else { break }
                guard let indexForElementWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == item.wrapperIdentifier }) else { break }
                
                guard !cast.userHasDeletedThis else {
                    aux.remove(at: indexForElementWithSameId)
                    break
                }
                
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
                
                if let indexForElementWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == item.wrapperIdentifier }) {
                    aux.remove(at: indexForElementWithSameId)
                    guard !cast.userHasDeletedThis else { break }
                    aux.insert(updatedCellVM, at: indexForElementWithSameId)
                } else {
                    aux.insert(updatedCellVM, at: 0)
                }
            case .track:
                guard let cast = item as? Track else { break }
                let updatedCellVM = ITunesSearchListCellViewModel(id: cast.wrapperIdentifier, title: cast.trackName, imageUrl: cast.artworkUrl60, cellType: .track, userHasSeenItem: cast.userHasSeenThis)
                if let indexForElementWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == item.wrapperIdentifier }) {
                    aux.remove(at: indexForElementWithSameId)
                    guard !cast.userHasDeletedThis else { break }
                    aux.insert(updatedCellVM, at: indexForElementWithSameId)
                } else {
                    aux.insert(updatedCellVM, at: 0)
                }
            default:
                break
            }
        }
        
        sharedState.dataSource.rows = aux
        
        return sharedState
    }
    
    private static func markRowWithItemIdAsSeen(_ id: Int64, wrapperType: SearchResultsWrapperType, sharedState: VMSharedState) -> VMSharedState {
        let mapWrapperTypeToCellVMType = mapWrapperTypeToCellTypeVM(wrapperType)
        
        guard
            let indexForElementWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == id && $0.cellType == mapWrapperTypeToCellVMType }),
            var itemVM = sharedState.dataSource.rows.first(where: { $0.id == id })
            else { return sharedState }
        
        var sharedState: VMSharedState = sharedState
        var aux: [ITunesSearchListCellViewModel] = sharedState.dataSource.rows
        
        itemVM.userHasSeenItem = true
        aux.remove(at: indexForElementWithSameId)
        aux.insert(itemVM, at: indexForElementWithSameId)
        
        sharedState.dataSource.rows = aux
        
        return sharedState
    }
    
    private static func markRowWithItemIdAsDeleted(_ id: Int64, wrapperType: SearchResultsWrapperType, sharedState: VMSharedState) -> VMSharedState {
        let mapWrapperTypeToCellVMType = mapWrapperTypeToCellTypeVM(wrapperType)
        
        guard
            let indexForElementWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == id && $0.cellType == mapWrapperTypeToCellVMType }),
            var itemVM = sharedState.dataSource.rows.first(where: { $0.id == id })
            else { return sharedState }
        
        var sharedState: VMSharedState = sharedState
        var aux: [ITunesSearchListCellViewModel] = sharedState.dataSource.rows
        
        aux.remove(at: indexForElementWithSameId)
        
        sharedState.dataSource.rows = aux
        
        return sharedState
    }
    
    private static func mapWrapperTypeToCellTypeVM(_ wrapperType: SearchResultsWrapperType) -> ITunesSearchListCellViewModel.CellType {
        switch wrapperType {
        case .audiobook:
            return .audioBook
        case .track:
            return .track
        default:
            return .unknown
        }
    }
}
