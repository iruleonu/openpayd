//
//  PostsListViewModelStateTests.swift
//  IRShowcaseTests
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSwift

@testable import IRShowcase

class PostsListViewModelStateTests: QuickSpec {
    override func spec() {
        describe("PostsListViewModelState") {
            var vmState: Atomic<(PostsListViewModelState.VMState, PostsListViewModelState.VMSharedState)>!
            
            beforeEach {
                let newSharedState = PostsListViewModelState.VMSharedState.empty
                let newState = PostsListViewModelState.VMState.empty
                vmState = Atomic((newState, newSharedState))
            }
            
            afterEach {
                let newSharedState = PostsListViewModelState.VMSharedState.empty
                let newState = PostsListViewModelState.VMState.empty
                vmState.modify({
                    $0.0 = newState
                    $0.1 = newSharedState
                })
            }
            
            describe("Shared State") {
                it("should have the correct number of rows after replacing posts") {
                    vmState.modify({ vmState in
                        var sharedState = vmState.1
                        let post1 = Post(id: 1, userId: 1, title: "1", body: "1")
                        let post2 = Post(id: 2, userId: 1, title: "2", body: "2")
                        let post3 = Post(id: 3, userId: 1, title: "3", body: "3")
                        let twoPosts = [post1, post2]
                        let threePosts = [post1, post2, post3]
                        
                        var sharedStateAction = PostsListViewModelState.SharedStateAction.replacePosts(threePosts)
                        sharedState = PostsListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.rows.count).to(equal(3))
                        
                        sharedStateAction = PostsListViewModelState.SharedStateAction.replacePosts(twoPosts)
                        sharedState = PostsListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.rows.count).to(equal(2))
                    })
                }
                
                it("should have the correct number of rows after updating or insert missing posts") {
                    vmState.modify({ vmState in
                        var sharedState = vmState.1
                        let post1 = Post(id: 1, userId: 1, title: "1", body: "1")
                        var post2 = Post(id: 2, userId: 1, title: "2", body: "2")
                        let post3 = Post(id: 3, userId: 1, title: "3", body: "3")
                        let twoPosts = [post1, post2]
                        let threePosts = [post1, post2, post3]
                        
                        var sharedStateAction = PostsListViewModelState.SharedStateAction.updatePosts(threePosts)
                        sharedState = PostsListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.rows.count).to(equal(0))
                        
                        sharedStateAction = PostsListViewModelState.SharedStateAction.updateOrInsertIfMissing(twoPosts)
                        sharedState = PostsListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.rows.count).to(equal(2))
                        
                        post2.title = "2b"
                        sharedStateAction = PostsListViewModelState.SharedStateAction.updatePosts([post2])
                        sharedState = PostsListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.rows.count).to(equal(2))
                        expect(sharedState.rows[0].title).to(equal("2b"))
                        
                        // Update post that isnt the array
                        sharedStateAction = PostsListViewModelState.SharedStateAction.updatePosts([post3])
                        sharedState = PostsListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.rows.count).to(equal(2))
                        
                        sharedStateAction = PostsListViewModelState.SharedStateAction.updateOrInsertIfMissing([post3])
                        sharedState = PostsListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.rows.count).to(equal(3))
                    })
                }
            }
        }
    }
}
