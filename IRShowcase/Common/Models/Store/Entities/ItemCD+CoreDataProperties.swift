//
//  ItemCD+CoreDataProperties.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 31/05/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//
//

import Foundation
import CoreData


extension ItemCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemCD> {
        return NSFetchRequest<ItemCD>(entityName: "ItemCD")
    }

    @NSManaged public var artistName: String?
    @NSManaged public var itemDescription: String?
    @NSManaged public var collectionName: String?
    @NSManaged public var artworkUrl60: String?
    @NSManaged public var artworkUrl100: String?
    @NSManaged public var artistId: Int64
    @NSManaged public var collectionId: Int64
    @NSManaged public var price: Float

}
