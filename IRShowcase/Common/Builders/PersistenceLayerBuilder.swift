//
//  PersistenceLayerBuilder.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 22/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import IRCoreDataStack

struct PersistenceLayerBuilder {
    static func make() -> PersistenceLayerImpl {
        let coreDataStack = IRCDStack(type: NSSQLiteStoreType, modelFilename: "IRShowcase", in: Bundle.main)!
        return PersistenceLayerImpl(coreDataStack: coreDataStack)
    }
}
