//
//  ConnectivityServiceBuilder.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 03/04/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import Connectivity

struct ConnectivityServiceBuilder {
    static func make() -> ConnectivityServiceImpl {
        return ConnectivityServiceImpl(connectivity: Connectivity())
    }
}
