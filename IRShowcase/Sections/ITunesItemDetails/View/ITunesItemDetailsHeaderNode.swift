//
//  ITunesItemDetailsHeaderNode.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 24/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ReactiveSwift

protocol ITunesItemDetailsHeaderDetails {
    var itemTitle: String { get }
    var itemSubtitle: String { get }
    var itemDescription: String { get }
    var itemImageUrl: String { get }
}

final class ITunesItemDetailsHeaderNode: ASCellNode {
    let imageNode: ASNetworkImageNode
    let nameNode: ASTextNode
    let usernameNode: ASTextNode
    let emailNode: ASTextNode
    private let disposables: CompositeDisposable
    
    struct NDesign {
        static let imageSize: CGSize = CGSize(width: 150, height: 150)
        static let insets: UIEdgeInsets = UIEdgeInsets.zero
    }
    
    required init(viewModel vm: ITunesItemDetailsViewModel) {
        imageNode = ITunesItemDetailsHeaderNode.setupImageNode(imageUrl: vm.itemImageUrl)
        nameNode = ITunesItemDetailsHeaderNode.setupNameNode(text: vm.itemTitle)
        usernameNode = ITunesItemDetailsHeaderNode.setupUsernameNode(text: vm.itemSubtitle)
        emailNode = ITunesItemDetailsHeaderNode.setupEmailNode(text: vm.itemDescription)
        disposables = CompositeDisposable()
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    deinit {
        disposables.dispose()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.style.width = ASDimensionMakeWithPoints(ITunesItemDetailsHeaderNode.NDesign.imageSize.width)
        imageNode.style.height = ASDimensionMakeWithPoints(ITunesItemDetailsHeaderNode.NDesign.imageSize.height)
        
        let mainSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.vertical,
                                         spacing: 10.0,
                                         justifyContent: ASStackLayoutJustifyContent.center,
                                         alignItems: ASStackLayoutAlignItems.center,
                                         children: [imageNode, nameNode, usernameNode, emailNode])
        mainSpec.style.preferredSize = constrainedSize.max
        return ASInsetLayoutSpec(insets: NDesign.insets, child: mainSpec)
    }
    
    func updateUI(viewModel vm: ITunesItemDetailsViewModel) {
        updateImageUrl(vm.itemImageUrl)
        updateNameNodeText(vm.itemTitle)
        updateUsernameNodeText(vm.itemSubtitle)
        updateEmailNodeText(vm.itemDescription)
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
        
        return aux
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
        aux.maximumNumberOfLines = 5
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
        aux.maximumNumberOfLines = 10
        aux.truncationMode = .byTruncatingTail
        aux.attributedText = NSAttributedString(string: text, attributes: attr)
        aux.isUserInteractionEnabled = false
        aux.placeholderEnabled = true
        
        return aux
    }
    
    private func updateImageUrl(_ imageUrl: String) {
        imageNode.url = URL(string: imageUrl)
    }
    
    private func updateNameNodeText(_ text: String) {
        let attr: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14.0)
        ]
        nameNode.attributedText = NSAttributedString(string: text, attributes: attr)
    }
    
    private func updateUsernameNodeText(_ text: String) {
        let attr: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14.0)
        ]
        usernameNode.attributedText = NSAttributedString(string: text, attributes: attr)
    }
    
    private func updateEmailNodeText(_ text: String) {
        let attr: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14.0)
        ]
        emailNode.attributedText = NSAttributedString(string: text, attributes: attr)
    }
}
