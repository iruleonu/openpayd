//
//  AudioBookCellNode.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 01/06/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ReactiveSwift

class AudioBookCellNode: ASCellNode {
    let imageNode: ASNetworkImageNode
    let titleTextNode: ASTextNode
    let subtitleTextNode: ASTextNode
    
    struct NDesign {
        static let size: CGSize = CGSize(width: 0, height: 75)
        static let imageSize: CGSize = CGSize(width: 75, height: 75)
        static let insets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    }
    
    required init(viewModel vm: ITunesSearchListCellViewModel) {
        imageNode = AudioBookCellNode.setupImageNode(imageUrl: vm.imageUrl)
        titleTextNode = AudioBookCellNode.setupTitleNode(text: "Audiobook")
        subtitleTextNode = AudioBookCellNode.setupSubtitleNode(text: vm.title)
        super.init()
        
        automaticallyManagesSubnodes = true
        
        onDidLoad { (node) in
            node.backgroundColor = vm.userHasSeenItem ? UIColor.blue : UIColor.white
        }
    }
    
    override var isHighlighted: Bool {
        willSet {
            let backgColor: UIColor = newValue ? UIColor.gray : UIColor.white
            backgroundColor = backgColor
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let verticalSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.vertical,
                                             spacing: 0.0,
                                             justifyContent: ASStackLayoutJustifyContent.start,
                                             alignItems: ASStackLayoutAlignItems.start,
                                             children: [titleTextNode, subtitleTextNode])
        
        imageNode.style.width = ASDimensionMakeWithPoints(AudioBookCellNode.NDesign.imageSize.width)
        imageNode.style.height = ASDimensionMakeWithPoints(AudioBookCellNode.NDesign.imageSize.height)
        
        let horizontalSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.horizontal,
                                               spacing: 5.0,
                                               justifyContent: ASStackLayoutJustifyContent.start,
                                               alignItems: ASStackLayoutAlignItems.start,
                                               children: [imageNode, verticalSpec])
        horizontalSpec.style.preferredSize = constrainedSize.max
        
        return ASInsetLayoutSpec(insets: NDesign.insets, child: horizontalSpec)
    }
    
    private static func setupImageNode(imageUrl: String) -> ASNetworkImageNode {
        let aux = ASNetworkImageNode()
        
        aux.url = URL(string: imageUrl)
        aux.contentMode = .scaleAspectFill
        aux.placeholderEnabled = true
        aux.placeholderColor = UIColor.gray
        aux.defaultImage = UIImage.as_imageNamed("AppIcon") ?? UIImage()
        aux.isLayerBacked = true
        aux.isOpaque = true
        aux.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
            return originalImage.apply(tintColor: UIColor.black.withAlphaComponent(0.25))
        }
        
        return aux
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
