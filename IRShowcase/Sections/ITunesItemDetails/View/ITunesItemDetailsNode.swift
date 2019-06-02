//
//  ITunesItemDetailsNode.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 24/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import AsyncDisplayKit

final class ITunesItemDetailsNode: ASDisplayNode {
    let headerNode: ITunesItemDetailsHeaderNode
    
    struct NDesign {
        static let insets: UIEdgeInsets = UIEdgeInsets.zero
    }
    
    required init(viewModel vm: ITunesItemDetailsViewModel) {
        headerNode = ITunesItemDetailsNode.setupHeaderNode(viewModel: vm)
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASWrapperLayoutSpec.wrapper(with: headerNode)
    }
    
    private static func setupHeaderNode(viewModel: ITunesItemDetailsViewModel) -> ITunesItemDetailsHeaderNode {
        let aux = ITunesItemDetailsHeaderNode(viewModel: viewModel)
        return aux
    }
}
