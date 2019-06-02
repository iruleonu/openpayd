//
//  RootCoordinator.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import UIKit

protocol RootRouting: class {
    func launchMainScreen()
    func launchOnBoarding()
}

final class RootCoordinator: RootRouting {
    private enum LaunchFlow {
        case onBoarding
        case mainScreen
    }
    
    private var window: UIWindow
    private let builders: RootChildBuilders
    
    init(window w: UIWindow, builders b: RootChildBuilders) {
        window = w
        builders = b
        handleLaunchFlow(LaunchFlow.mainScreen)
    }
    
    func launchMainScreen() {
        window.rootViewController = builders.makeMainScreen()
    }
    
    func launchOnBoarding() {
        window.rootViewController = builders.makeOnBoarding()
    }
    
    private func handleLaunchFlow(_ launchFlow: LaunchFlow) {
        switch launchFlow {
        case .mainScreen:
            launchMainScreen()
        case .onBoarding:
            launchOnBoarding()
        }
    }
}
