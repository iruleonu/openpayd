//
//  SearchItemResponse+Persistence.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 01/06/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

extension SearchItemResponse: NestedCodableToPersistence {
    var codablesToPersistence: [CodableToPersistence] {
        return results.compactMap({ $0 as? CodableToPersistence })
    }
}
