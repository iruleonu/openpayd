//
//  CoreDataToCodableProtocol.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 22/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import enum Result.Result
import CoreData

public enum CoreDataToCodableError: Error {
    case unkown
    case custom(String)
    
    var description: String {
        switch self {
        case .custom(let description):
            return description
        case .unkown:
            return "Unknown error"
        }
    }
}

protocol CoreDataToCodable {
    static func mapToModel<T: Codable>(_ object: NSManagedObject) -> T?
    static func mapToModelResult<T: Codable>(_ object: NSManagedObject) -> Result<T, CoreDataToCodableError>
}
