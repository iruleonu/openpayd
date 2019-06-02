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
protocol ITunesItemDetailsRouting: class {
    func dismissScreen()
}

final class ITunesItemDetailsCoordinator {
    private weak var navigation: UINavigationController?
    private let builders: ITunesItemDetailsChildBuilders
    
    init(navigation nav: UINavigationController?, builders b: ITunesItemDetailsChildBuilders) {
        navigation = nav
        builders = b
    }
}

extension ITunesItemDetailsCoordinator: ITunesItemDetailsRouting {
    func dismissScreen() {
        navigation?.popViewController(animated: true)
    }
}
