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
        switch route {
        case .intro:
            let viewController: RootViewController = RootViewController()
            let coordinator: RootViewCoordinator = RootViewCoordinator(provider: provider, rootViewController: viewController)
            
            // initial view
            let introViewController = IntroViewController()
            let introViewCoordinator = IntroViewCoordinator(provider: provider, rootViewController: introViewController)
            let introViewReactor = IntroViewReactor()
            
            // DI
            viewController.coordinator = coordinator
            
            introViewController.coordinator = introViewCoordinator
            introViewController.reactor = introViewReactor
            
            // initialize root view
            viewController.viewControllers = [introViewController]
            
            // present view
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
}
