//
//  AppCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

enum AppRoute {
    case intro
}

/// Route from app initialze
class AppCoordinator {
    // MARK: properties
    let window: UIWindow
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol, window: UIWindow) {
        self.provider = provider
        self.window = window
    }
    
    func present(for route: AppRoute) {
        switch route {
        case .intro:
            let coordinator: RootViewCoordinator = RootViewCoordinator(provider: provider)
            let viewController: RootViewController = coordinator.rootViewController
            
            // initialize view
            let introViewCoordinator: IntroViewCoordinator = IntroViewCoordinator(provider: provider)
            let introViewController: IntroViewController = introViewCoordinator.rootViewController
            
            // initialize root view
            viewController.viewControllers = [introViewController]
            
            // present view
            self.window.rootViewController = viewController
            self.window.makeKeyAndVisible()
        }
    }
}
