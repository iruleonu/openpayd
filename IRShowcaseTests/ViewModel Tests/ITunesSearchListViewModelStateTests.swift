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

class ITunesSearchListViewModelStateTests: QuickSpec {
    override func spec() {
        describe("ITunesSearchListViewModelState") {
            var vmState: Atomic<(ITunesSearchListViewModelState.VMState, ITunesSearchListViewModelState.VMSharedState)>!
            
            beforeEach {
                let newSharedState = ITunesSearchListViewModelState.VMSharedState.empty
                let newState = ITunesSearchListViewModelState.VMState.empty
                vmState = Atomic((newState, newSharedState))
            }
            
            afterEach {
                let newSharedState = ITunesSearchListViewModelState.VMSharedState.empty
                let newState = ITunesSearchListViewModelState.VMState.empty
                vmState.modify({
                    $0.0 = newState
                    $0.1 = newSharedState
                })
            }
            
            describe("Shared State") {
                it("should have the correct number of rows after replacing posts") {
                    vmState.modify({ vmState in
                        var sharedState = vmState.1
                        let item1 = Track(trackId: 1, trackName: "1", trackDescription: "1", collectionPrice: 1, artworkUrl60: "", artworkUrl100: "", userHasSeenThis: false, userHasDeletedThis: false)
                        let item2 = Track(trackId: 2, trackName: "2", trackDescription: "2", collectionPrice: 2, artworkUrl60: "", artworkUrl100: "", userHasSeenThis: false, userHasDeletedThis: false)
                        let item3 = Track(trackId: 3, trackName: "3", trackDescription: "3", collectionPrice: 3, artworkUrl60: "", artworkUrl100: "", userHasSeenThis: false, userHasDeletedThis: false)
                        let twoPosts = [item1, item2]
                        let threePosts = [item1, item2, item3]
                        
                        var sharedStateAction = ITunesSearchListViewModelState.SharedStateAction.replacePosts(threePosts)
                        sharedState = ITunesSearchListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.dataSource.rows.count).to(equal(3))
                        
                        sharedStateAction = ITunesSearchListViewModelState.SharedStateAction.replacePosts(twoPosts)
                        sharedState = ITunesSearchListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.dataSource.rows.count).to(equal(2))
                    })
                }
                
                it("should have the correct number of rows after updating or insert missing posts") {
                    vmState.modify({ vmState in
                        var sharedState = vmState.1
                        let item1 = Track(trackId: 1, trackName: "1", trackDescription: "1", collectionPrice: 1, artworkUrl60: "", artworkUrl100: "", userHasSeenThis: false, userHasDeletedThis: false)
                        let item2 = Track(trackId: 2, trackName: "2", trackDescription: "2", collectionPrice: 2, artworkUrl60: "", artworkUrl100: "", userHasSeenThis: false, userHasDeletedThis: false)
                        let item3 = Track(trackId: 3, trackName: "3", trackDescription: "3", collectionPrice: 3, artworkUrl60: "", artworkUrl100: "", userHasSeenThis: false, userHasDeletedThis: false)
                        let twoPosts = [item1, item2]
                        let threePosts = [item1, item2, item3]
                        
                        var sharedStateAction = ITunesSearchListViewModelState.SharedStateAction.updatePosts(threePosts)
                        sharedState = ITunesSearchListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.dataSource.rows.count).to(equal(0))
                        
                        sharedStateAction = ITunesSearchListViewModelState.SharedStateAction.updateOrInsertIfMissing(twoPosts)
                        sharedState = ITunesSearchListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.dataSource.rows.count).to(equal(2))
                        
                        let item2WithDifferentTrackName = Track(trackId: 2, trackName: "2b", trackDescription: "2", collectionPrice: 2, artworkUrl60: "", artworkUrl100: "", userHasSeenThis: false, userHasDeletedThis: false)
                        sharedStateAction = ITunesSearchListViewModelState.SharedStateAction.updatePosts([item2WithDifferentTrackName])
                        sharedState = ITunesSearchListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.dataSource.rows.count).to(equal(2))
                        expect(sharedState.dataSource.rows[0].title).to(equal("2b"))
                        
                        // Update post that isnt the array
                        sharedStateAction = ITunesSearchListViewModelState.SharedStateAction.updatePosts([item3])
                        sharedState = ITunesSearchListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.dataSource.rows.count).to(equal(2))
                        
                        sharedStateAction = ITunesSearchListViewModelState.SharedStateAction.updateOrInsertIfMissing([item3])
                        sharedState = ITunesSearchListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        expect(sharedState.dataSource.rows.count).to(equal(3))
                    })
                }
            }
        }
    }
}
