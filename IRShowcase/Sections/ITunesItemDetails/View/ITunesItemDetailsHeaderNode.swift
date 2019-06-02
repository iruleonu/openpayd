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

final class ITunesItemDetailsHeaderNode: ASCellNode {
    let nameNode: ASTextNode
    let usernameNode: ASTextNode
    let emailNode: ASTextNode
    private let disposables: CompositeDisposable
    
    struct NDesign {
        static let size: CGSize = CGSize(width: 0, height: 150)
        static let insets: UIEdgeInsets = UIEdgeInsets.zero
    }
    
    required init(viewModel vm: ITunesItemDetailsViewModel) {
        nameNode = ITunesItemDetailsHeaderNode.setupNameNode(text: vm.posterName)
        usernameNode = ITunesItemDetailsHeaderNode.setupUsernameNode(text: vm.posterUsername)
        emailNode = ITunesItemDetailsHeaderNode.setupEmailNode(text: vm.posterEmail)
        disposables = CompositeDisposable()
        super.init()
        automaticallyManagesSubnodes = true
        setupBindings(viewModel: vm)
    }
    
    deinit {
        disposables.dispose()
    }
    
    private func setupBindings(viewModel vm: ITunesItemDetailsViewModel) {
        disposables += vm.refreshSupplementaryElementOfKind.signal.observeValues { [weak self] (_) in
            self?.updateUI(viewModel: vm)
            self?.setNeedsLayout()
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let mainSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.vertical,
                                         spacing: 0.0,
                                         justifyContent: ASStackLayoutJustifyContent.center,
                                         alignItems: ASStackLayoutAlignItems.center,
                                         children: [nameNode, usernameNode, emailNode])
        mainSpec.style.preferredSize = constrainedSize.max
        return ASInsetLayoutSpec(insets: NDesign.insets, child: mainSpec)
    }
    
    private func updateUI(viewModel vm: ITunesItemDetailsViewModel) {
        updateNameNodeText(vm.posterName)
        updateUsernameNodeText(vm.posterUsername)
        updateEmailNodeText(vm.posterEmail)
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
