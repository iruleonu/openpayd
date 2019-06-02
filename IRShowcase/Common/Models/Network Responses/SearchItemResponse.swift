//
//  SearchItemResponse.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 31/05/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

struct SearchItemResponse: Codable {
    let resultCount: Int
    let results: [SearchResultsWrapperModelTypeProtocol]
    
    enum CodingKeys: String, CodingKey {
        case resultCount
        case results
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let resultCount = try container.decode(Int.self, forKey: .resultCount)
        var results: [SearchResultsWrapperModelTypeProtocol] = []
        
        // Two arrays, the first one checks the type, the second parses the concrete type
        var nestedUnkeyedGenericResultsArray = try container.nestedUnkeyedContainer(forKey: .results)
        var nestedUnkeyedConcreteResultsArray = try container.nestedUnkeyedContainer(forKey: .results)
        while !nestedUnkeyedGenericResultsArray.isAtEnd {
            let genericModel = try nestedUnkeyedGenericResultsArray.decode(SearchResultWrapperModelType.self)
            
            switch genericModel.wrapperType {
            case .track:
                let concreteType = try nestedUnkeyedConcreteResultsArray.decode(Track.self)
                results.append(concreteType)
            case .audiobook:
                let concreteType = try nestedUnkeyedConcreteResultsArray.decode(AudioBook.self)
                results.append(concreteType)
            default:
                _ = try nestedUnkeyedConcreteResultsArray.decode(SearchResultWrapperModelType.self)
            }
        }
        
        self.init(resultCount: resultCount, results: results)
    }
    
    public func encode(to encoder: Encoder) throws {
        var baseContainer = encoder.container(keyedBy: CodingKeys.self)
        try baseContainer.encode(resultCount, forKey: .resultCount)
        let resultsEncoder = baseContainer.superEncoder(forKey: .results)
        var unkeyedContainer = resultsEncoder.unkeyedContainer()
        for wrappedModel in results {
            let subencoder = unkeyedContainer.superEncoder()
            try (wrappedModel as! Encodable).encode(to: subencoder) // swiftlint:disable:this force_cast
        }
    }
    
    init() {
        self.resultCount = 0
        self.results = []
    }
    
    init(resultCount: Int, results: [SearchResultsWrapperModelTypeProtocol]) {
        self.resultCount = resultCount
        self.results = results
    }
}
