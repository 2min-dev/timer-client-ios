//
//  AppDelegate.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // init SwiftBeaver
        Logger.initialize()
        
        // create new window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // present intro view
        let appCoordinator: AppCoordinator = AppCoordinator(provider: ServiceProvider(), window: self.window!)
        appCoordinator.present(for: .intro)
        return true
    }
}
