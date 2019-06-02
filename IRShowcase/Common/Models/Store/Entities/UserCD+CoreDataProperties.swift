//
//  UserCD+CoreDataProperties.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//
//

import Foundation
import CoreData

extension UserCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCD> {
        return NSFetchRequest<UserCD>(entityName: "UserCD")
    }

    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var username: String?
    @NSManaged public var id: Int64

}
