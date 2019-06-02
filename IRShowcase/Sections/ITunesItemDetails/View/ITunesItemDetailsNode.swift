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
    let collectionNodeFlowLayout: ITunesItemDetailsCollectionViewLayout
    let collectionLayoutInspector: ITunesItemDetailsCollectionViewLayoutInspector
    let collectionNode: ASCollectionNode
    let refreshControl: UIRefreshControl
    
    struct NDesign {
        static let insets: UIEdgeInsets = UIEdgeInsets.zero
    }
    
    required init(viewModel vm: ITunesItemDetailsViewModel) {
        refreshControl = UIRefreshControl()
        collectionNodeFlowLayout = ITunesItemDetailsCollectionViewLayout()
        collectionLayoutInspector = ITunesItemDetailsCollectionViewLayoutInspector(layout: collectionNodeFlowLayout)
        collectionNode = ITunesItemDetailsNode.setupCollectionNode(flowLayout: collectionNodeFlowLayout, layoutInspector: collectionLayoutInspector)
        super.init()
        automaticallyManagesSubnodes = true
        
        onDidLoad { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.collectionNode.view.refreshControl = strongSelf.refreshControl
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASWrapperLayoutSpec.wrapper(with: collectionNode)
    }
    
    private static func setupNameNode(text: String) -> ASTextNode {
        let aux = ASTextNode()
        
        let attr: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14.0)
        ]
        aux.maximumNumberOfLines = 1
        aux.truncationMode = .byTruncatingTail
        aux.attributedText = NSAttributedString(string: text, attributes: attr)
        aux.isUserInteractionEnabled = false
        aux.placeholderEnabled = true
        
        return aux
    }
    
    private static func setupUsernameNode(text: String) -> ASTextNode {
        let aux = ASTextNode()
        
        let attr: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        aux.maximumNumberOfLines = 2
        aux.truncationMode = .byTruncatingTail
        aux.attributedText = NSAttributedString(string: text, attributes: attr)
        aux.isUserInteractionEnabled = false
        aux.placeholderEnabled = true
        
        return aux
    }
    
    private static func setupEmailNode(text: String) -> ASTextNode {
        let aux = ASTextNode()
        
        let attr: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        aux.maximumNumberOfLines = 2
        aux.truncationMode = .byTruncatingTail
        aux.attributedText = NSAttributedString(string: text, attributes: attr)
        aux.isUserInteractionEnabled = false
        aux.placeholderEnabled = true
        
        return aux
    }
    
    private static func setupCollectionNode(flowLayout: ITunesItemDetailsCollectionViewLayout, layoutInspector: ITunesItemDetailsCollectionViewLayoutInspector) -> ASCollectionNode {
        let aux = ASCollectionNode(collectionViewLayout: flowLayout)
        aux.backgroundColor = UIColor.white
        aux.layoutInspector = layoutInspector
        aux.registerSupplementaryNode(ofKind: UICollectionView.elementKindSectionHeader)
        return aux
    }
}
