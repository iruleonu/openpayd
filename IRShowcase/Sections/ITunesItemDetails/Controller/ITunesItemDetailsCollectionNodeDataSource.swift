//
//  ITunesItemDetailsCollectionNodeDataSource.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 24/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ReactiveSwift

enum ITunesItemDetailsSupplementaryElementOfKinds {
    case header
}

protocol ITunesItemDetailsCollectionNodeDataSourceHeaderDetails {
    var posterName: String { get }
    var posterUsername: String { get }
    var posterEmail: String { get }
    var refreshSupplementaryElementOfKind: MutableProperty<ITunesItemDetailsSupplementaryElementOfKinds> { get }
}

protocol ITunesItemDetailsCollectionNodeDataSourceProtocol: ITunesItemDetailsCollectionNodeDataSourceHeaderDetails {
    func numberOfSections(dataSource: ITunesItemDetailsViewModelState.VMSharedState.DataSource) -> Int
    func numberOfRowsInSection(_ section: Int, dataSource: ITunesItemDetailsViewModelState.VMSharedState.DataSource) -> Int
}

class ITunesItemDetailsCollectionNodeDataSource: NSObject, ASCollectionDataSource {
    let dataSource: ITunesItemDetailsCollectionNodeDataSourceProtocol
    var cachedState: ITunesItemDetailsViewModelState.VMSharedState.DataSource
    let viewModel: ITunesItemDetailsViewModel
    
    required init(viewModel vm: ITunesItemDetailsViewModel) {
        dataSource = vm
        cachedState = .empty
        viewModel = vm
        super.init()
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfRowsInSection(section, dataSource: cachedState)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard dataSource.numberOfRowsInSection(indexPath.section, dataSource: cachedState) > indexPath.row else { return { ASCellNode() } }

        let postVM = cachedState.rows[indexPath.row]
        let cellNodeBlock = { () -> ASCellNode in
            return ITunesItemDetailsCellNode(viewModel: postVM)
        }
        return cellNodeBlock
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNodeBlock {
        let vm = viewModel
        let headerNodeBlock = { () -> ASCellNode in
            return ITunesItemDetailsHeaderNode(viewModel: vm)
        }
        return headerNodeBlock
    }
}
