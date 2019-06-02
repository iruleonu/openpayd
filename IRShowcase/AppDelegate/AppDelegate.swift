//
//  AppDelegate.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var rootCoordinator: RootCoordinator?
    lazy var services: [AppService] = [APIServiceImpl.default, PersistenceLayerImpl.default, ConnectivityServiceImpl.default]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Bail out early if we're running as a test harness.
        guard NSClassFromString("XCTestCase") == nil else { return true }
        
        let window = UIWindow()
        services.forEach({ _ = $0.application(application, didFinishLaunchingWithOptions: launchOptions) })
        rootCoordinator = RootBuilder().make(window: window)
        window.makeKeyAndVisible()
        return true
    }
}
