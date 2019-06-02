//
//  PersistenceLayerErrors.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 22/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

enum PersistenceLayerError: Error {
    case unknown
    case persistence(error: Error)
    case emptyResult(error: Error?)
    case disabled
    
    var errorDescription: String {
        switch self {
        case .persistence:
            return "Persistence error"
        case .emptyResult:
            return "No results for requested resource"
        case .disabled:
            return "Persistence disabled"
        default:
            return "Unknown error"
        }
    }
}
