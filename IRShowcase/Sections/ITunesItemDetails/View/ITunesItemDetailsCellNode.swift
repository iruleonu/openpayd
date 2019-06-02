//
//  ITunesItemDetailsCellNode.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 25/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ReactiveSwift

class ITunesItemDetailsCellNode: ASCellNode {
    let titleTextNode: ASTextNode
    let subtitleTextNode: ASTextNode
    
    struct NDesign {
        static let size: CGSize = CGSize(width: 0, height: 55)
        static let insets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    }
    
    required init(viewModel vm: ITunesItemDetailsCellViewModel) {
        titleTextNode = ITunesItemDetailsCellNode.setupTitleNode(text: vm.title)
        subtitleTextNode = ITunesItemDetailsCellNode.setupSubtitleNode(text: vm.subtitle)
        super.init()
        
        automaticallyManagesSubnodes = true
    }
    
    override var isHighlighted: Bool {
        willSet {
            let backgColor: UIColor = newValue ? UIColor.gray : UIColor.white
            backgroundColor = backgColor
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let mainSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.vertical,
                                         spacing: 0.0,
                                         justifyContent: ASStackLayoutJustifyContent.start,
                                         alignItems: ASStackLayoutAlignItems.start,
                                         children: [titleTextNode, subtitleTextNode])
        mainSpec.style.preferredSize = constrainedSize.max
        return ASInsetLayoutSpec(insets: NDesign.insets, child: mainSpec)
    }
    
    private static func setupTitleNode(text: String) -> ASTextNode {
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
    
    private static func setupSubtitleNode(text: String) -> ASTextNode {
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
}
