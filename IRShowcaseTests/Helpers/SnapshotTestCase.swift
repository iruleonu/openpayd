//
//  SnapshotTestCase.swift
//  IRShowcaseTests
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import FBSnapshotTestCase
import AsyncDisplayKit

class SnapshotTestCase: FBSnapshotTestCase {
    func sizeNodeToFitSize(_ node: ASDisplayNode, size: CGSize) {
        let sizeThatFits = node.layoutThatFits(ASSizeRangeMake(size)).size
        node.bounds = CGRect(origin: CGPoint.zero, size: sizeThatFits)
    }
    
    func verifyNode(_ node: ASDisplayNode) {
        synchronouslyRecursivelyRenderNode(node)
        FBSnapshotVerifyLayer(node.layer)
    }
    
    private func synchronouslyRecursivelyRenderNode(_ node: ASDisplayNode) {
        ASDisplayNodePerformBlockOnEveryNode(nil, node, true) { (n) in
            n.layer.setNeedsDisplay()
        }
        node.recursivelyEnsureDisplaySynchronously(true)
    }
}
