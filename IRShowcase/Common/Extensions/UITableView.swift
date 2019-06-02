//
//  UITableView.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import Doppelganger

extension UITableView {
    public func diffApplyChangesForSections(_ changes: [WMLArrayDiff], completion block: ((Bool) -> Void)?) {
        var insertion: IndexSet = IndexSet.init()
        var deletion: IndexSet = IndexSet.init()
        var moving: [WMLArrayDiff] = []
        
        for diff in changes {
            switch diff.type {
            case .delete:
                deletion.insert(Int(diff.previousIndex))
            case .insert:
                insertion.insert(Int(diff.currentIndex))
            case .move:
                moving.append(diff)
            @unknown default:
                break
            }
        }
        
        performBatchUpdates({
            insertSections(insertion, with: .automatic)
            deleteSections(deletion, with: .automatic)
            for diff in moving {
                moveSection(Int(diff.previousIndex), toSection: Int(diff.currentIndex))
            }
        }, completion: block)
    }
    
    public func diffApplyChangesForRows(_ changes: [WMLArrayDiff], section: Int, completion block: ((Bool) -> Void)?) {
        var insertion: [IndexPath] = []
        var deletion: [IndexPath] = []
        var moving: [WMLArrayDiff] = []
        
        for diff in changes {
            switch diff.type {
            case .delete:
                let indexPath = IndexPath.init(item: Int(diff.previousIndex), section: section)
                deletion.append(indexPath)
            case .insert:
                let indexPath = IndexPath.init(item: Int(diff.currentIndex), section: section)
                insertion.append(indexPath)
            case .move:
                moving.append(diff)
            @unknown default:
                break
            }
        }
        
        performBatchUpdates({
            insertRows(at: insertion, with: .automatic)
            deleteRows(at: deletion, with: .automatic)
            for diff in moving {
                let atIndexPath = IndexPath(item: Int(diff.previousIndex), section: section)
                let toIndexPath = IndexPath(item: Int(diff.currentIndex), section: section)
                moveRow(at: atIndexPath, to: toIndexPath)
            }
        }, completion: block)
    }
    
    func indexPathIsValid(indexPath: IndexPath) -> Bool {
        if indexPath.section >= self.numberOfSections {
            return false
        }
        if indexPath.row >= numberOfRows(inSection: indexPath.section) {
            return false
        }
        return true
    }
}
