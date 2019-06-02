//
//  RootBuilder.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import UIKit

protocol RootChildBuilders {
    func makeMainScreen() -> UIViewController
    func makeOnBoarding() -> UIViewController
}

struct RootBuilder: RootChildBuilders {
    func make(window: UIWindow) -> RootCoordinator {
        return RootCoordinator(window: window, builders: self)
    }
    
    func makeMainScreen() -> UIViewController {
        let navigation = UINavigationController()
        let network = APIServiceImpl.default
        let persistence = PersistenceLayerImpl.default
        let connectivity = ConnectivityServiceImpl.default
        let vc = ITunesSearchListBuilder().make(navigation: navigation, network: network, dataProviderPersistence: persistence, searchListPersistence: persistence, connectivity: connectivity)
        navigation.setViewControllers([vc], animated: false)
        navigation.navigationBar.prefersLargeTitles = true
        return navigation
    }
    
    func makeOnBoarding() -> UIViewController {
        // TODO: on boarding
        let navigation = UINavigationController()
        let network = APIServiceImpl.default
        let persistence = PersistenceLayerImpl.default
        let connectivity = ConnectivityServiceImpl.default
        let vc = ITunesSearchListBuilder().make(navigation: navigation, network: network, dataProviderPersistence: persistence, searchListPersistence: persistence, connectivity: connectivity)
        navigation.setViewControllers([vc], animated: false)
        navigation.navigationBar.prefersLargeTitles = true
        return navigation
    }
}
