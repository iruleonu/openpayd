//
//  AudioBook.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 31/05/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

struct AudioBook: Codable {
    let collectionId: Int64
    let artistId: Int64
    let artistName: String
    let itemDescription: String
    let collectionName: String
    let artworkUrl60: String
    let artworkUrl100: String
    let collectionPrice: Float
    let userHasSeenThis: Bool
    let userHasDeletedThis: Bool
    
    enum CodingKeys: String, CodingKey {
        case collectionId
        case artistId
        case artistName
        case itemDescription = "description"
        case collectionName
        case artworkUrl60
        case artworkUrl100
        case collectionPrice
        case wrapperTypeName = "wrapperType"
        case userHasSeenThis
        case userHasDeletedThis
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let artistId = try container.decode(Int64.self, forKey: .artistId)
        let collectionId = try container.decode(Int64.self, forKey: .collectionId)
        let artistName = try container.decode(String.self, forKey: .artistName)
        let itemDescription = try container.decode(String.self, forKey: .itemDescription)
        let collectionName = try container.decode(String.self, forKey: .collectionName)
        let artworkUrl60 = try container.decode(String.self, forKey: .artworkUrl60)
        let artworkUrl100 = try container.decode(String.self, forKey: .artworkUrl100)
        let collectionPrice = try container.decode(Float.self, forKey: .collectionPrice)
        let userHasSeenThis = try container.decodeIfPresent(Bool.self, forKey: .userHasSeenThis) ?? false
        let userHasDeletedThis = try container.decodeIfPresent(Bool.self, forKey: .userHasDeletedThis) ?? false
        self.init(artistId: artistId, collectionId: collectionId, artistName: artistName, itemDescription: itemDescription, collectionName: collectionName, artworkUrl60: artworkUrl60, artworkUrl100: artworkUrl100, collectionPrice: collectionPrice, userHasSeenThis: userHasSeenThis, userHasDeletedThis: userHasDeletedThis)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(artistId, forKey: .artistId)
        try container.encode(collectionId, forKey: .collectionId)
        try container.encode(artistName, forKey: .artistName)
        try container.encode(itemDescription, forKey: .itemDescription)
        try container.encode(collectionName, forKey: .collectionName)
        try container.encode(artworkUrl60, forKey: .artworkUrl60)
        try container.encode(artworkUrl100, forKey: .artworkUrl100)
        try container.encode(collectionPrice, forKey: .collectionPrice)
        try container.encode(wrapperTypeName, forKey: .wrapperTypeName)
        try container.encode(userHasSeenThis, forKey: .userHasSeenThis)
        try container.encode(userHasDeletedThis, forKey: .userHasDeletedThis)
    }
    
    init(artistId: Int64, collectionId: Int64, artistName: String, itemDescription: String, collectionName: String, artworkUrl60: String, artworkUrl100: String, collectionPrice: Float, userHasSeenThis: Bool, userHasDeletedThis: Bool) {
        self.artistId = artistId
        self.collectionId = collectionId
        self.artistName = artistName
        self.itemDescription = itemDescription
        self.collectionName = collectionName
        self.artworkUrl60 = artworkUrl60
        self.artworkUrl100 = artworkUrl100
        self.collectionPrice = collectionPrice
        self.userHasSeenThis = userHasSeenThis
        self.userHasDeletedThis = userHasDeletedThis
    }
}

extension AudioBook: SearchResultsWrapperModelTypeProtocol {
    var wrapperType: SearchResultsWrapperType {
        return SearchResultsWrapperType.audiobook
    }
    
    var wrapperTypeName: String {
        return SearchResultsWrapperType.audiobook.description
    }
    
    var wrapperIdentifier: Int64 {
        return collectionId
    }
}

extension AudioBook: Equatable {
    static func == (left: AudioBook, right: AudioBook) -> Bool {
        return left.collectionId == right.collectionId
    }
}

//extension AudioBook: WrapperModelType {
//    var wrapperTypeName: String {
//        return WrapperType.audiobook.description
//    }
//    
//    var wrapperIdentifier: Int64 {
//        return collectionId
//    }
//}
