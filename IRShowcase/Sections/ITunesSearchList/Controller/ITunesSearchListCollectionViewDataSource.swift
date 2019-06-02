//
//  ITunesSearchListCollectionNodeDataSource.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ReactiveSwift
import Result

protocol ITunesSearchListCollectionNodeDataSourceProtocol {
    func numberOfSections(dataSource: ITunesSearchListViewModelState.VMSharedState.DataSource) -> Int
    func numberOfRowsInSection(_ section: Int, dataSource: ITunesSearchListViewModelState.VMSharedState.DataSource) -> Int
}

class ITunesSearchListCollectionNodeDataSource: NSObject, ASCollectionDataSource {
    let dataSource: ITunesSearchListCollectionNodeDataSourceProtocol
    var cachedState: ITunesSearchListViewModelState.VMSharedState.DataSource
    
    required init(viewModel vm: ITunesSearchListCollectionNodeDataSourceProtocol) {
        dataSource = vm
        cachedState = .empty
        super.init()
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfRowsInSection(section, dataSource: cachedState)
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard dataSource.numberOfRowsInSection(indexPath.section, dataSource: cachedState) > indexPath.row else { return { ASCellNode() } }
        
        let cellVM = cachedState.rows[indexPath.row]
        let cellNodeBlock = { () -> ASCellNode in
            switch cellVM.cellType {
            case .audioBook:
                return AudioBookCellNode(viewModel: cellVM)
            case .track:
                return TrackCellNode(viewModel: cellVM)
            default:
                return ASCellNode()
            }
        }
        return cellNodeBlock
    }
}
