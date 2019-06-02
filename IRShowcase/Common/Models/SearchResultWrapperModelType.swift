//
//  WrapperType.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 31/05/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

enum SearchResultsWrapperType: CustomStringConvertible {
    case unknown
    case track
    case audiobook
    
    enum Constants {
        static let audioBookTypeName = "audiobook"
        static let trackTypeName = "track"
    }
    
    var description: String {
        switch self {
        case .audiobook:
            return Constants.audioBookTypeName
        case .track:
            return Constants.trackTypeName
        default:
            return "unknown"
        }
    }
    
    init(rawType: String) {
        switch rawType {
        case Constants.audioBookTypeName:
            self = .audiobook
        case Constants.trackTypeName:
            self = .track
        default:
            self = .unknown
        }
    }
}

protocol SearchResultsWrapperModelTypeProtocol {
    var wrapperType: SearchResultsWrapperType { get }
    var wrapperTypeName: String { get }
    var wrapperIdentifier: Int64 { get }
}

struct SearchResultWrapperModelType: Codable {
    var wrapperTypeName: String
    
    enum CodingKeys: String, CodingKey {
        case wrapperTypeName = "wrapperType"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let wrapperType = try container.decode(String.self, forKey: .wrapperTypeName)
        self.init(wrapperType: wrapperType)
    }
    
    init(wrapperType: String) {
        self.wrapperTypeName = wrapperType
    }
}

extension SearchResultWrapperModelType: CodingKey {
    init?(stringValue: String) {
        self.wrapperTypeName = stringValue
    }
    
    var stringValue: String {
        return wrapperTypeName
    }
    
    var intValue: Int? {
        return 0
    }
    
    init?(intValue: Int) {
        wrapperTypeName = SearchResultsWrapperType.unknown.description
    }
}

extension SearchResultWrapperModelType {
    var wrapperType: SearchResultsWrapperType {
        switch wrapperTypeName {
        case SearchResultsWrapperType.Constants.trackTypeName:
            return .track
        case SearchResultsWrapperType.Constants.audioBookTypeName:
            return .audiobook
        default:
            return .unknown
        }
    }
}

extension SearchResultWrapperModelType: Equatable {
    static func == (left: SearchResultWrapperModelType, right: SearchResultWrapperModelType) -> Bool {
        return left.wrapperTypeName == right.wrapperTypeName
    }
}
