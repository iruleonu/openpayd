//
//  PostCD+CoreDataProperties.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 31/05/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//
//

import Foundation
import CoreData


extension PostCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostCD> {
        return NSFetchRequest<PostCD>(entityName: "PostCD")
    }

    @NSManaged public var body: String?
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var userId: Int64
    @NSManaged public var userHasSeenPost: Bool

}
