//
//  Track.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 31/05/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

struct Track: Codable {
    let trackId: Int64
    let trackName: String
    let trackDescription: String?
    let collectionPrice: Float
    let artworkUrl60: String
    let artworkUrl100: String
    let userHasSeenThis: Bool
    let userHasDeletedThis: Bool
    
    enum CodingKeys: String, CodingKey {
        case trackId
        case trackName
        case trackDescription = "shortDescription"
        case collectionPrice
        case artworkUrl60
        case artworkUrl100
        case wrapperTypeName = "wrapperType"
        case userHasSeenThis
        case userHasDeletedThis
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let trackId = try container.decode(Int64.self, forKey: .trackId)
        let trackName = try container.decode(String.self, forKey: .trackName)
        let trackDescription = try container.decodeIfPresent(String.self, forKey: .trackDescription)
        let collectionPrice = try container.decode(Float.self, forKey: .collectionPrice)
        let artworkUrl60 = try container.decode(String.self, forKey: .artworkUrl60)
        let artworkUrl100 = try container.decode(String.self, forKey: .artworkUrl100)
        let userHasSeenThis = try container.decodeIfPresent(Bool.self, forKey: .userHasSeenThis) ?? false
        let userHasDeletedThis = try container.decodeIfPresent(Bool.self, forKey: .userHasDeletedThis) ?? false
        self.init(trackId: trackId, trackName: trackName, trackDescription: trackDescription, collectionPrice: collectionPrice, artworkUrl60: artworkUrl60, artworkUrl100: artworkUrl100, userHasSeenThis: userHasSeenThis, userHasDeletedThis: userHasDeletedThis)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(trackId, forKey: .trackId)
        try container.encode(trackName, forKey: .trackName)
        try container.encode(trackDescription, forKey: .trackDescription)
        try container.encode(collectionPrice, forKey: .collectionPrice)
        try container.encode(artworkUrl60, forKey: .artworkUrl60)
        try container.encode(artworkUrl100, forKey: .artworkUrl100)
        try container.encode(wrapperTypeName, forKey: .wrapperTypeName)
    }
    
    init(trackId: Int64, trackName: String, trackDescription: String?, collectionPrice: Float, artworkUrl60: String, artworkUrl100: String, userHasSeenThis: Bool, userHasDeletedThis: Bool) {
        self.trackId = trackId
        self.trackName = trackName
        self.trackDescription = trackDescription
        self.collectionPrice = collectionPrice
        self.artworkUrl60 = artworkUrl60
        self.artworkUrl100 = artworkUrl100
        self.userHasSeenThis = userHasSeenThis
        self.userHasDeletedThis = userHasDeletedThis
    }
}

extension Track: SearchResultsWrapperModelTypeProtocol {
    var wrapperType: SearchResultsWrapperType {
        return SearchResultsWrapperType.track
    }
    
    var wrapperTypeName: String {
        return SearchResultsWrapperType.track.description
    }
    
    var wrapperIdentifier: Int64 {
        return trackId
    }
}

extension Track: Equatable {
    static func == (left: Track, right: Track) -> Bool {
        return left.trackId == right.trackId
    }
}
