//
//  PostsListViewModelState.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

final class PostsListViewModelState {
    struct VMState {
        static let empty = VMState()
    }
    
    struct VMSharedState {
        struct DataSource {
            var rows: [PostsListCellViewModel]
            static let empty = DataSource(rows: [])
        }
        
        var dataSource: DataSource
        static let empty = VMSharedState(dataSource: .empty)
    }
    
    enum StateAction {
        // No actions
    }
    
    enum SharedStateAction {
        case replacePosts([Post])
        case updatePosts([Post])
        case updateOrInsertIfMissing([Post])
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
        case let .replacePosts(posts):
            sharedState = replacePosts(posts, sharedState: sharedState)
        case let .updatePosts(posts):
            sharedState = updatePosts(posts, sharedState: sharedState)
        case let .updateOrInsertIfMissing(posts):
            sharedState = updateOrInsertIfMissing(posts, sharedState: sharedState)
        case .reset:
            sharedState = .empty
        }
        
        return sharedState
    }
    
    static func handleHybridStateAction(_ action: HybridAction, sharedState: VMSharedState, state: VMState) -> (VMSharedState, VMState) {
        return (sharedState, state)
    }
    
    private static func replacePosts(_ posts: [Post], sharedState: VMSharedState) -> VMSharedState {
        var sharedState: VMSharedState = sharedState
        
        var aux: [PostsListCellViewModel] = []
        
        posts.forEach { (post) in
            aux.append(PostsListCellViewModel(id: post.id, title: post.title, subtitle: post.body))
        }
        
        sharedState.dataSource.rows = aux
        
        return sharedState
    }
    
    private static func updatePosts(_ posts: [Post], sharedState: VMSharedState) -> VMSharedState {
        var sharedState: VMSharedState = sharedState
        
        var aux: [PostsListCellViewModel] = sharedState.dataSource.rows
        
        posts.forEach { (post) in
            guard let indexForPostWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == post.id }) else { return }
            let updatedViewModel = PostsListCellViewModel(id: post.id, title: post.title, subtitle: post.body)
            aux.remove(at: indexForPostWithSameId)
            aux.insert(updatedViewModel, at: indexForPostWithSameId)
        }
        
        sharedState.dataSource.rows = aux
        
        return sharedState
    }
    
    private static func updateOrInsertIfMissing(_ posts: [Post], sharedState: VMSharedState) -> VMSharedState {
        var sharedState: VMSharedState = sharedState
        
        var aux: [PostsListCellViewModel] = sharedState.dataSource.rows
        
        posts.forEach { (post) in
            let postViewModel = PostsListCellViewModel(id: post.id, title: post.title, subtitle: post.body)
            guard let indexForPostWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == post.id }) else {
                aux.insert(postViewModel, at: 0)
                return
            }
            aux.remove(at: indexForPostWithSameId)
            aux.insert(postViewModel, at: indexForPostWithSameId)
        }
        
        sharedState.dataSource.rows = aux
        
        return sharedState
    }
}
