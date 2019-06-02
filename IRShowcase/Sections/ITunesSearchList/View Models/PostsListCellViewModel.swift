//
//  PostsListCellViewModel.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

struct PostsListCellViewModel {
    let id: Int
    let title: String
    let subtitle: String
    
    init(id: Int, title: String, subtitle: String) {
        self.id = id
        self.title = title.isEmpty ? " " : title
        self.subtitle = subtitle.replacingOccurrences(of: "\n", with: " ")
    }
}

extension PostsListCellViewModel: Hashable, Comparable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(subtitle)
    }
    
    static func < (lhs: PostsListCellViewModel, rhs: PostsListCellViewModel) -> Bool {
        return lhs.id > rhs.id
    }
    
    static func == (lhs: PostsListCellViewModel, rhs: PostsListCellViewModel) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }
}
