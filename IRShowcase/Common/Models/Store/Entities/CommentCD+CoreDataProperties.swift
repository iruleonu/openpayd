//
//  CommentCD+CoreDataProperties.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//
//

import Foundation
import CoreData

extension CommentCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CommentCD> {
        return NSFetchRequest<CommentCD>(entityName: "CommentCD")
    }

    @NSManaged public var body: String?
    @NSManaged public var email: String?
    @NSManaged public var id: Int64
    @NSManaged public var postId: Int64
    @NSManaged public var name: String?

}
