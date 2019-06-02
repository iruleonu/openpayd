//
//  AudioBookCD+CoreDataProperties.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 31/05/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//
//

import Foundation
import CoreData


extension AudioBookCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioBookCD> {
        return NSFetchRequest<AudioBookCD>(entityName: "AudioBookCD")
    }

    @NSManaged public var id: Int64
    @NSManaged public var artistId: Int64
    @NSManaged public var artistName: String?
    @NSManaged public var artworkUrl60: String?
    @NSManaged public var artworkUrl100: String?
    @NSManaged public var collectionId: Int64
    @NSManaged public var collectionName: String?
    @NSManaged public var itemDescription: String?
    @NSManaged public var collectionPrice: Float
    @NSManaged public var wrapperType: String?
    @NSManaged public var userHasSeenThis: Bool
    @NSManaged public var userHasDeletedThis: Bool
    
}
