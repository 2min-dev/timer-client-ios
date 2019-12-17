//
//  AppCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from app initialze
class AppCoordinator: LaunchCoordinator, ServiceContainer {
    // MARK: - route enumeration
    enum Route {
        case intro
    }

    // MARK: - properties
    var window: UIWindow
    var provider: ServiceProviderProtocol
    
    // MARK: - constructor
    init(window: UIWindow, provider: ServiceProviderProtocol) {
        self.window = window
        self.provider = provider
    }
    
    // MARK: - presentation
    @discardableResult
    func present(for route: Route) -> UIViewController? {
        guard let (controller, _) = get(for: route) else { return nil }
        
        var presentingViewController = controller
        switch route {
        case .intro:
            // Wrap view to naviagtion container
            presentingViewController = BaseNavicationController(rootViewController: presentingViewController)
            // Present intro view
            window.rootViewController = presentingViewController
            window.makeKeyAndVisible()
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .intro:
            let dependency = IntroViewBuilder.Dependency(provider: provider)
            return IntroViewBuilder(with: dependency).build()
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
