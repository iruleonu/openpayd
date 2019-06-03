//
//  ITunesItemDetailsViewController.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import ReactiveSwift
import enum Result.NoError
import Doppelganger

class ITunesItemDetailsViewController: ASViewController<ITunesItemDetailsNode> {
    private let viewModel: ITunesItemDetailsViewModel
    private var disposables = CompositeDisposable()
    
    init(viewModel vm: ITunesItemDetailsViewModel) {
        viewModel = vm
        let rootNode = ITunesItemDetailsNode(viewModel: vm)
        super.init(node: rootNode)
    }
    
    deinit {
        disposables.dispose()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        node.backgroundColor = UIColor.white
        navigationItem.title = viewModel.screenTitle
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.largeTitleDisplayMode = .automatic
        setupNavigationBarItems()
        setupBindings()
        viewModel.inputs.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.rightBarButtonItem = nil
    }
    
    private func setupNavigationBarItems() {
        let newOrderButton = UIBarButtonItem(
            title: "Delete",
            style: .plain,
            target: self,
            action: #selector(self.userDidTapDeleteButton(_:))
        )
        
        self.navigationItem.rightBarButtonItem = newOrderButton
    }
    
    private func setupBindings() {
        disposables += viewModel.outputs.dataSourceChanges
            .observeValues { [weak self] _ in
            self?.updateUI()
        }
        
        disposables += viewModel.outputs.fetchedStuff
            .observe(on: QueueScheduler.main)
            .observeValues({ [weak self] _ in
                self?.updateUI()
            })
    }
    
    private func updateUI() {
        self.node.headerNode.updateUI(viewModel: viewModel)
    }
}

// MARK: Actions
extension ITunesItemDetailsViewController {
    @objc func userDidTapDeleteButton(_ sender: UIBarButtonItem) {
        viewModel.inputs.userDidTapDeleteButton(sourceVC: self)
    }
}
