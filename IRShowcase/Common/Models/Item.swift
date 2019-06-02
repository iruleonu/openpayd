//
//  Item.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 31/05/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

struct Item: Codable {
    let artistId: Int64
    let collectionId: Int64
    let artistName: String
    let itemDescription: String
    let collectionName: String
    let artworkUrl60: String
    let artworkUrl100: String
    let price: Float
    
    enum CodingKeys: String, CodingKey {
        case artistId
        case collectionId
        case artistName
        case itemDescription = "description"
        case collectionName
        case artworkUrl60
        case artworkUrl100
        case price = "collectionPrice"
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
        let price = try container.decode(Float.self, forKey: .price)
        self.init(artistId: artistId, collectionId: collectionId, artistName: artistName, itemDescription: itemDescription, collectionName: collectionName, artworkUrl60: artworkUrl60, artworkUrl100: artworkUrl100, price: price)
    }
    
    init(artistId: Int64, collectionId: Int64, artistName: String, itemDescription: String, collectionName: String, artworkUrl60: String, artworkUrl100: String, price: Float) {
        self.artistId = artistId
        self.collectionId = collectionId
        self.artistName = artistName
        self.itemDescription = itemDescription
        self.collectionName = collectionName
        self.artworkUrl60 = artworkUrl60
        self.artworkUrl100 = artworkUrl100
        self.price = price
    }
}

extension Item: Equatable {
    static func == (left: Item, right: Item) -> Bool {
        return left.collectionId == right.collectionId
    }
}
