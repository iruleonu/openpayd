//
//  PostDetailsViewModelState.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 24/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

final class PostDetailsViewModelState {
    struct VMState {
        var post: Post?
        var user: User?
        static let empty = VMState(post: nil, user: nil)
    }
    
    struct VMSharedState {
        struct DataSource {
            var rows: [PostDetailsCellViewModel]
            static let empty = DataSource(rows: [])
        }
        
        var dataSource: DataSource
        static let empty = VMSharedState(dataSource: DataSource.empty)
    }
    
    enum StateAction {
        case insertPost(Post)
        case insertPosterDetails(User)
    }
    
    enum SharedStateAction {
        case insertOrUpdateComments([Comment])
    }
    
    enum HybridAction {
        // No actions
    }
    
    static func handleStateAction(_ action: StateAction, state: VMState) -> VMState {
        var state = state
        
        switch action {
        case .insertPost(let post):
            state.post = post
        case .insertPosterDetails(let user):
            state.user = user
        }
        
        return state
    }
    
    static func handleSharedStateAction(_ action: SharedStateAction, sharedState: VMSharedState) -> VMSharedState {
        var sharedState = sharedState
        
        switch action {
        case .insertOrUpdateComments(let comments):
            sharedState = updateOrInsertIfMissing(comments, sharedState: sharedState)
        }
        
        return sharedState
    }
    
    static func handleHybridStateAction(_ action: HybridAction, sharedState: VMSharedState, state: VMState) -> (VMSharedState, VMState) {
        return (sharedState, state)
    }
    
    private static func updateOrInsertIfMissing(_ comments: [Comment], sharedState: VMSharedState) -> VMSharedState {
        var sharedState: VMSharedState = sharedState
        
        var aux: [PostDetailsCellViewModel] = sharedState.dataSource.rows
        
        comments.forEach { (comment) in
            let postViewModel = PostDetailsCellViewModel.init(id: comment.id, title: comment.name, subtitle: comment.body)
            guard let indexForPostWithSameId = sharedState.dataSource.rows.firstIndex(where: { $0.id == comment.id }) else {
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
