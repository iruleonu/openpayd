//
//  ITunesSearchListViewController.swift
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

class ITunesSearchListViewController: ASViewController<ITunesSearchListNode> {
    private let viewModel: ITunesSearchListViewModel
    private var dataSource: ITunesSearchListCollectionNodeDataSource
    private var shouldThrottleWhilePerformingUpdates: MutableProperty<Bool>
    private let performUpdatesSignal: Signal<ITunesSearchListViewModelState.VMSharedState.DataSource, NoError>
    private let performUpdatesObserver: Signal<ITunesSearchListViewModelState.VMSharedState.DataSource, NoError>.Observer
    private var disposables = CompositeDisposable()
    
    init(viewModel vm: ITunesSearchListViewModel) {
        viewModel = vm
        dataSource = ITunesSearchListCollectionNodeDataSource(viewModel: vm)
        shouldThrottleWhilePerformingUpdates = MutableProperty(false)
        (performUpdatesSignal, performUpdatesObserver) = Signal<ITunesSearchListViewModelState.VMSharedState.DataSource, NoError>.pipe()
        
        let rootNode = ITunesSearchListNode(viewModel: vm)
        super.init(node: rootNode)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        node.collectionNode.delegate = nil
        node.collectionNode.dataSource = nil
        disposables.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "50 iTunes Items"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.largeTitleDisplayMode = .automatic
        configureCollectionNode()
        setupBindings()
        viewModel.inputs.viewDidLoad()
        node.refreshControl.addTarget(self, action: #selector(triggerRefreshControl(_:)), for: .valueChanged)
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
    
    private func performUpdates(newState: ITunesSearchListViewModelState.VMSharedState.DataSource, completion block: (() -> Void)?) {
        shouldThrottleWhilePerformingUpdates.value = true
        let oldState = dataSource.cachedState
        dataSource.cachedState = newState
        renderDiff(oldState, newState: dataSource.cachedState, completion: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.shouldThrottleWhilePerformingUpdates.value = false
            block?()
        })
    }
    
    private func renderDiff(_ oldState: ITunesSearchListViewModelState.VMSharedState.DataSource, newState: ITunesSearchListViewModelState.VMSharedState.DataSource, completion block: (() -> Void)?) {
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

extension ITunesSearchListViewController: ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        guard dataSource.cachedState.rows.count > indexPath.row else { return }
        let cellVM = dataSource.cachedState.rows[indexPath.row]
        
        switch cellVM.cellType {
        case .audioBook:
            viewModel.inputs.userDidTapAudioBookCellWithAudioBookId(cellVM.id)
        case .track:
            viewModel.inputs.userDidTapTrackCellWithTrackId(cellVM.id)
        default:
            break
        }
    }
}

extension ITunesSearchListViewController: PostsListCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: ITunesSearchListCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
        return CGSize(width: node.collectionNode.calculatedSize.width, height: TrackCellNode.NDesign.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, headerSizeForSection: Int) -> CGSize {
        return CGSize.zero
    }
}
