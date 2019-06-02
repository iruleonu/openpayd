//
//  CoreDataStackBuilder.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import IRCoreDataStack

struct CoreDataStackBuilder {
    func make() -> IRCDStack {
        return IRCDStack(type: NSSQLiteStoreType, modelFilename: "IRShowcase", in: Bundle.main)!
    }
}
