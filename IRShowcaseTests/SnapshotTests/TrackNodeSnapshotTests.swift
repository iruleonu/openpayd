//
//  TrackNodeSnapshotTests.swift
//  IRShowcaseTests
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import AsyncDisplayKit

@testable import IRShowcase

class TrackNodeSnapshotTests: SnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }
    
    // Nodes
    func testTrackNodeOneLineSubtitle() {
        let desiredSize = CGSize(width: 325, height: TrackCellNode.NDesign.size.height)
        let cellViewModel = ITunesSearchListCellViewModel(id: 1, title: "Test title", imageUrl: "", cellType: .track, userHasSeenItem: false)
        let node = TrackCellNode(viewModel: cellViewModel)
        sizeNodeToFitSize(node, size: desiredSize)
        verifyNode(node)
    }
    
    func testTrackNodeTwoLineSubtitle() {
        let desiredSize = CGSize(width: 325, height: TrackCellNode.NDesign.size.height)
        let cellViewModel = ITunesSearchListCellViewModel(id: 1, title: "Subtitling uahsdon uahsdon uahsdon uahsdon uahsdon uahsdon uahsdon uahsdon uahsdon uahsdon uahsdon", imageUrl: "", cellType: .track, userHasSeenItem: false)
        let node = TrackCellNode(viewModel: cellViewModel)
        sizeNodeToFitSize(node, size: desiredSize)
        verifyNode(node)
    }
    
    func testTrackNodeNoTitle() {
        let desiredSize = CGSize(width: 325, height: TrackCellNode.NDesign.size.height)
        let cellViewModel = ITunesSearchListCellViewModel(id: 1, title: "", imageUrl: "", cellType: .track, userHasSeenItem: false)
        let node = TrackCellNode(viewModel: cellViewModel)
        sizeNodeToFitSize(node, size: desiredSize)
        verifyNode(node)
    }
}
