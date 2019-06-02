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
    private let dataSource: ITunesItemDetailsCollectionNodeDataSource
    private var shouldThrottleWhilePerformingUpdates: MutableProperty<Bool>
    private let performUpdatesSignal: Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>
    private let performUpdatesObserver: Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>.Observer
    private var disposables = CompositeDisposable()
    
    init(viewModel vm: ITunesItemDetailsViewModel) {
        viewModel = vm
        dataSource = ITunesItemDetailsCollectionNodeDataSource(viewModel: vm)
        shouldThrottleWhilePerformingUpdates = MutableProperty(false)
        (performUpdatesSignal, performUpdatesObserver) = Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>.pipe()
        let rootNode = ITunesItemDetailsNode(viewModel: vm)
        super.init(node: rootNode)
    }
    
    deinit {
        node.collectionNode.delegate = nil
        node.collectionNode.dataSource = nil
        disposables.dispose()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        node.backgroundColor = UIColor.white
        navigationItem.title = "Post details"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.largeTitleDisplayMode = .automatic
        configureCollectionNode()
        node.collectionNode.reloadData()
        setupBindings()
        viewModel.inputs.viewDidLoad()
        node.refreshControl.addTarget(self, action: #selector(triggerRefreshControl(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewDidAppear()
    }
    
    private func configureCollectionNode() {
        node.collectionNodeFlowLayout.delegate = self
        node.collectionNode.backgroundColor = UIColor.white
        node.collectionNode.delegate = self
        node.collectionNode.dataSource = dataSource
        node.collectionNode.view.delaysContentTouches = false
        node.collectionNode.view.canCancelContentTouches = true
        node.collectionNode.view.panGestureRecognizer.maximumNumberOfTouches = 1
    }
    
    private func setupBindings() {
        disposables += viewModel.outputs.dataSourceChanges
            .observeValues { [weak self] newState in
                guard let strongSelf = self else { return }
                strongSelf.performUpdatesObserver.send(value: newState)
        }
        
        disposables += viewModel.outputs.fetchedStuff
            .observe(on: QueueScheduler.main)
            .observeValues({ [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.node.refreshControl.endRefreshing()
            })
        
        disposables += performUpdatesSignal
            .throttle(while: shouldThrottleWhilePerformingUpdates, on: QueueScheduler.main)
            .observeValues { [weak self] newState in
                guard let strongSelf = self else { return }
                strongSelf.performUpdates(newState: newState, completion: nil)
        }
    }
    
    private func performUpdates(newState: ITunesItemDetailsViewModelState.VMSharedState.DataSource, completion block: (() -> Void)?) {
        shouldThrottleWhilePerformingUpdates.value = true
        let oldState = dataSource.cachedState
        dataSource.cachedState = newState
        renderDiff(oldState, newState: dataSource.cachedState, completion: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.shouldThrottleWhilePerformingUpdates.value = false
            block?()
        })
    }
    
    private func renderDiff(_ oldState: ITunesItemDetailsViewModelState.VMSharedState.DataSource, newState: ITunesItemDetailsViewModelState.VMSharedState.DataSource, completion block: (() -> Void)?) {
        let oldDataForRow = oldState.rows
        let newDataForRow = newState.rows
        let rowDiff = ArrayDiffUtility.diff(currentArray: newDataForRow, previousArray: oldDataForRow)
        
        node.collectionNode.diffApplyChangesForRows(rowDiff, section: 0) { _ in
            block?()
        }
    }
    
    // MARK: Actions
    @objc private func triggerRefreshControl(_ sender: UIRefreshControl) {
        viewModel.inputs.triggerRefreshControl()
    }
}

extension ITunesItemDetailsViewController: ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ITunesItemDetailsViewController: ASCollectionDelegateFlowLayout {
    func collectionNode(_ collectionNode: ASCollectionNode, sizeRangeForHeaderInSection section: Int) -> ASSizeRange {
        return ASSizeRangeUnconstrained
    }
}

extension ITunesItemDetailsViewController: ITunesItemDetailsCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: ITunesItemDetailsCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
        return CGSize(width: self.node.calculatedSize.width, height: TrackCellNode.NDesign.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, headerSizeForSection: Int) -> CGSize {
        return CGSize(width: self.node.calculatedSize.width, height: ITunesItemDetailsHeaderNode.NDesign.size.height)
    }
}
