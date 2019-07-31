//
//  AppCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from app initialze
class AppCoordinator {
    // MARK: route enumeration
    enum AppRoute {
        case intro
    }

    // MARK: properties
    let window: UIWindow
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol, window: UIWindow) {
        self.provider = provider
        self.window = window
    }
    
    func present(for route: AppRoute) {
        let viewController = get(for: route)
        
        switch route {
        case .intro:
            // Present intro view
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
    
    func get(for route: AppRoute) -> UIViewController {
        switch route {
        case .intro:
            // initial view
            let introViewController = IntroViewController()
            let introViewCoordinator = IntroViewCoordinator(provider: provider, rootViewController: introViewController)
            let introViewReactor = IntroViewReactor()
            
            // DI
            introViewController.coordinator = introViewCoordinator
            introViewController.reactor = introViewReactor
            
            let viewController: RootViewController = RootViewController(rootViewController: introViewController)
            return viewController
        }
    }
}
