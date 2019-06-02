//
//  PersistenceLayer+Post.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 03/06/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import CoreData
import ReactiveSwift

protocol EntityFetchPostsProtocol {
    func fetchAllPosts() -> SignalProducer<[Post], PersistenceLayerError>
    func fetchPost(postId: Int64) -> SignalProducer<[Post], PersistenceLayerError>
}

extension PersistenceLayerImpl: EntityFetchPostsProtocol {
    func fetchAllPosts() -> SignalProducer<[Post], PersistenceLayerError> {
        let context = coreDataStack.managedObjectContext!
        
        return SignalProducer<[Post], PersistenceLayerError> { observer, _ in
            var results: [Post] = []
            
            do {
                let fetchRequest: NSFetchRequest<PostCD> = PostCD.fetchRequest()
                let aux = try context.fetch(fetchRequest) as [PostCD]
                aux.forEach({ (postCD) in
                    guard let post: Post = Post.mapToModel(postCD) else { return }
                    results.append(post)
                })
            } catch {}
            
            guard results.count > 0 else {
                let error = NSError.error(withMessage: "No results when trying to fetch all posts")
                observer.send(error: PersistenceLayerError.emptyResult(error: error))
                return
            }
            
            observer.send(value: results)
        }
    }
    
    func fetchPost(postId: Int64) -> SignalProducer<[Post], PersistenceLayerError> {
        let context = coreDataStack.managedObjectContext!
        
        return SignalProducer<[Post], PersistenceLayerError> { observer, _ in
            var results: [Post] = []
            
            do {
                let fetchRequest: NSFetchRequest<PostCD> = PostCD.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %lld", Int64(postId))
                let aux = try context.fetch(fetchRequest) as [PostCD]
                aux.forEach({ (postCD) in
                    guard let post: Post = Post.mapToModel(postCD) else { return }
                    results.append(post)
                })
            } catch {}
            
            guard results.count > 0 else {
                let error = NSError.error(withMessage: "No results for post with id: \(postId)")
                observer.send(error: PersistenceLayerError.emptyResult(error: error))
                return
            }
            
            observer.send(value: results)
        }
    }
}
