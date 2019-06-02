//
//  ITunesSearchListCellViewModel.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

struct ITunesSearchListCellViewModel {
    enum CellType {
        case unknown
        case track
        case audioBook
    }
    
    let cellType: CellType
    let id: Int64
    let title: String
    let imageUrl: String
    var userHasSeenItem: Bool
    
    init(id: Int64, title: String, imageUrl: String, cellType: CellType, userHasSeenItem: Bool) {
        self.id = id
        self.title = title.isEmpty ? " " : title
        self.imageUrl = imageUrl
        self.cellType = cellType
        self.userHasSeenItem = userHasSeenItem
    }
}

extension ITunesSearchListCellViewModel: Hashable, Comparable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(imageUrl)
        hasher.combine(userHasSeenItem)
    }
    
    static func < (lhs: ITunesSearchListCellViewModel, rhs: ITunesSearchListCellViewModel) -> Bool {
        return lhs.id > rhs.id
    }
    
    static func == (lhs: ITunesSearchListCellViewModel, rhs: ITunesSearchListCellViewModel) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.imageUrl == rhs.imageUrl && lhs.imageUrl == rhs.imageUrl
    }
}
