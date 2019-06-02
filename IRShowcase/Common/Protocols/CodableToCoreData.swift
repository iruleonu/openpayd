//
//  CodableToPersistence.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 22/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

protocol CodableToPersistence {
    // Name of the CD entity that the class is going to represent
    var entityName: String { get }
    
    // Name of the properties that are represented has another CD companion class
    var relationshipPropertyNames: [String] { get }
    
    // Name of the properties that have a mapping with a different name in CD
    var propertiesToRemoveSavingEachPropertyValueAndSetItToTargetKey: [String: String] { get } // swiftlint:disable:this identifier_name
    
    // Dictionary without CD relationships, to import insert to CD without conflicts
    var dictionaryWithoutCDRelationships: [String: AnyObject] { get }
    
    // Dictionary without CD relationships, to import insert to CD without conflicts
    func dictionaryForCDRelationshipPropertyNamed(_ property: String) -> [String: AnyObject]?
    
    // Object id (not NSManagedObjectID)
    var identifier: String { get }
}

protocol NestedCodableToPersistence {
    var codablesToPersistence: [CodableToPersistence] { get }
}
