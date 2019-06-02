//
//  SearchResultsCodableContainer.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 31/05/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

struct SearchResultsCodableContainer: Codable {
    let results: [SearchResultsWrapperModelTypeProtocol]
    
    enum CodingKeys: String, CodingKey {
        case results
    }
    
    init(from decoder: Decoder) throws {
        self.init()
    }
    func encode(to encoder: Encoder) throws { }
    
    init() {
        self.results = []
    }
    
    init(results: [SearchResultsWrapperModelTypeProtocol]) {
        self.results = results
    }
}
