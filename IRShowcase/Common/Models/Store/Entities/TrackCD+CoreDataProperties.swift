//
//  TrackCD+CoreDataProperties.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 31/05/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//
//

import Foundation
import CoreData


extension TrackCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackCD> {
        return NSFetchRequest<TrackCD>(entityName: "TrackCD")
    }

    @NSManaged public var id: Int64
    @NSManaged public var artistName: String?
    @NSManaged public var trackName: String?
    @NSManaged public var collectionPrice: Float
    @NSManaged public var trackDescription: String?
    @NSManaged public var artworkUrl60: String?
    @NSManaged public var artworkUrl100: String?
    @NSManaged public var wrapperType: String?
    @NSManaged public var userHasSeenThis: Bool
    @NSManaged public var userHasDeletedThis: Bool
    
}
