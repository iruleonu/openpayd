//
//  ITunesSearchListCollectionViewLayout.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

protocol PostsListCollectionViewLayoutDelegate: ASCollectionDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: ITunesSearchListCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize
    func collectionView(_ collectionView: UICollectionView, headerSizeForSection: Int) -> CGSize
}

class ITunesSearchListCollectionViewLayout: UICollectionViewFlowLayout {
    public weak var delegate: PostsListCollectionViewLayoutDelegate?
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.scrollDirection = .vertical
        let screenSize = UIScreen.main.bounds
        itemSize = CGSize(width: screenSize.width, height: screenSize.height)
        minimumInteritemSpacing = 5
        minimumLineSpacing = 5
    }
    
    func itemSizeAtIndexPath(indexPath: IndexPath) -> CGSize {
        return self.delegate!.collectionView(self.collectionView!, layout: self, originalItemSizeAtIndexPath: indexPath)
    }
    
    func headerSizeForSection(section: Int) -> CGSize {
        let originalSize = self.delegate!.collectionView(self.collectionView!, headerSizeForSection: section)
        return originalSize
    }
}

class PostsListCollectionViewLayoutInspector: NSObject, ASCollectionViewLayoutInspecting {
    var layout: ITunesSearchListCollectionViewLayout?
    
    init(layout l: ITunesSearchListCollectionViewLayout) {
        super.init()
        layout = l
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        guard let layout = layout else { return ASSizeRangeZero }
        return ASSizeRangeMake(CGSize.zero, layout.itemSizeAtIndexPath(indexPath: indexPath))
    }
    
    // swiftlint:disable identifier_name
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForSupplementaryNodeOfKind: String, at atIndexPath: IndexPath) -> ASSizeRange {
        guard let layout = layout else { return ASSizeRangeZero }
        return ASSizeRange(min: CGSize.zero, max: layout.headerSizeForSection(section: atIndexPath.section))
    }
    // swiftlint:enable identifier_name
    
    /**
     * Asks the inspector for the number of supplementary sections in the collection view for the given kind.
     */
    func collectionView(_ collectionView: ASCollectionView, numberOfSectionsForSupplementaryNodeOfKind kind: String) -> UInt {
        if kind == UICollectionView.elementKindSectionHeader {
            return UInt((collectionView.dataSource?.numberOfSections!(in: collectionView))!)
        } else {
            return 0
        }
    }
    
    /**
     * Asks the inspector for the number of supplementary views for the given kind in the specified section.
     */
    func collectionView(_ collectionView: ASCollectionView, supplementaryNodesOfKind kind: String, inSection section: UInt) -> UInt {
        if kind == UICollectionView.elementKindSectionHeader {
            return 1
        } else {
            return 0
        }
    }
    
    func scrollableDirections() -> ASScrollDirection {
        return ASScrollDirectionVerticalDirections
    }
}
