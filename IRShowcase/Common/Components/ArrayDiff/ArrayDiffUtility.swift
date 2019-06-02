//
//  ArrayDiffUtility.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import Doppelganger

/// Helper class for Doppelganger to deal with the fact that collection operation dont work properly
// if the object being worked upon is a plain swift object (only conforms to Hashable and not NSObject).
/// https://stackoverflow.com/questions/33319959/nsobject-subclass-in-swift-hash-vs-hashvalue-isequal-vs
open class ArrayDiffUtility<T: Hashable> {
    public var previousArray: [T]
    public var currentArray: [T]
    public var diff: [WMLArrayDiff]
    
    public static func diff(currentArray: [T], previousArray: [T]) -> [WMLArrayDiff] {
        let utility = ArrayDiffUtility.init(currentArray: currentArray, previousArray: previousArray)
        utility.performDiff()
        return utility.diff
    }
    
    public init(currentArray: [T], previousArray: [T]) {
        self.currentArray = currentArray
        self.previousArray = previousArray
        self.diff = []
    }
    
    private func performDiff() {
        let oldSet = Set(previousArray)
        let newSet = Set(currentArray)
        let deletedObjects = oldSet.subtracting(newSet)
        let insertedObjects = newSet.subtracting(oldSet)
        
        let moveDiffs: [WMLArrayDiff] = movementDiffs(deletedObjects: deletedObjects, insertedObjects: insertedObjects)
        let deletionDiffs: [WMLArrayDiff] = deletionsForArray(array: previousArray, deletedObjects: deletedObjects)
        let insertionDiffs: [WMLArrayDiff] = insertionForArray(array: currentArray, insertedObjects: insertedObjects)
        
        var results: [WMLArrayDiff] = []
        results += deletionDiffs
        results += insertionDiffs
        results += moveDiffs
        
        diff = results
    }
    
    private func movementDiffs(deletedObjects: Set<T>, insertedObjects: Set<T>) -> [WMLArrayDiff] {
        var result: [WMLArrayDiff] = []
        var delta: Int = 0
        for (leftIdx, leftObj) in previousArray.enumerated() {
            if deletedObjects.contains(leftObj) {
                delta += 1
                continue
            }
            
            var localDelta: Int = delta
            var rightIdx: Int = 0
            for rightObj in currentArray {
                if insertedObjects.contains(rightObj) {
                    localDelta -= 1
                    rightIdx += 1
                    continue
                }
                if rightObj != leftObj {
                    rightIdx += 1
                    continue
                }
                
                let adjustedRightIdx = rightIdx + localDelta
                if leftIdx != rightIdx && adjustedRightIdx != leftIdx {
                    guard let wml = WMLArrayDiff.init(forMoveFrom: UInt(leftIdx), to: UInt(rightIdx)) else { continue }
                    result.append(wml)
                }
                rightIdx += 1
            }
        }
        
        return result
    }
    
    private func deletionsForArray(array: [T], deletedObjects: Set<T>) -> [WMLArrayDiff] {
        var result: [WMLArrayDiff] = []
        
        for (index, element) in array.enumerated() {
            guard deletedObjects.contains(element) else { continue }
            guard let wml = WMLArrayDiff.init(forDeletionAt: UInt(index)) else { continue }
            result.append(wml)
        }
        
        return result
    }
    
    private func insertionForArray(array: [T], insertedObjects: Set<T>) -> [WMLArrayDiff] {
        var result: [WMLArrayDiff] = []
        
        for (index, element) in array.enumerated() {
            guard insertedObjects.contains(element) else { continue }
            guard let wml = WMLArrayDiff.init(forInsertionAt: UInt(index)) else { continue }
            result.append(wml)
        }
        
        return result
    }
}
