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
    // MARK: - route enumeration
    enum Route {
        case intro
    }

    // MARK: - properties
    let window: UIWindow
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    init(provider: ServiceProviderProtocol, window: UIWindow) {
        self.provider = provider
        self.window = window
    }
    
    func present(for route: Route) {
        let viewController = get(for: route)
        
        switch route {
        case .intro:
            // Present intro view
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
    
    func get(for route: Route) -> UIViewController {
        switch route {
        case .intro:
            let introViewCoordinator = IntroViewCoordinator(provider: provider)
            let introViewReactor = IntroViewReactor(appService: provider.appService, timeSetService: provider.timeSetService)
            let introViewController = IntroViewController(coordinator: introViewCoordinator)
            
            // DI
            introViewCoordinator.viewController = introViewController
            introViewController.reactor = introViewReactor
            
            let viewController: RootViewController = RootViewController(rootViewController: introViewController)
            return viewController
        }
    }
}
