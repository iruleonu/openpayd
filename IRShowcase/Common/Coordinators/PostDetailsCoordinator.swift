//
//  PostDetailsCoordinator.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

import UIKit

//sourcery: AutoMockable
protocol PostDetailsRouting: class {
    // Empty
}

final class PostDetailsCoordinator: PostDetailsRouting {
    private weak var navigation: UINavigationController?
    private let builders: ITunesItemDetailsChildBuilders
    
    init(navigation nav: UINavigationController?, builders b: ITunesItemDetailsChildBuilders) {
        navigation = nav
        builders = b
    }
}
