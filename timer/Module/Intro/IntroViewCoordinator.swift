//
//  IntroCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from intro view
class IntroViewCoordinator: CoordinatorProtocol {
     // MARK: route enumeration
    enum IntroRoute {
        case main
    }
    
    // MARK: properties
    weak var rootViewController: IntroViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: IntroViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    func present(for route: IntroRoute) -> UIViewController {
        let viewController = get(for: route)
        
        switch route {
        case .main:
            // Present main view
            rootViewController.navigationController?.viewControllers = [viewController]
        }
        
        return viewController
    }
    
    func get(for route: IntroRoute) -> UIViewController {
        switch route {
        case .main:
            let viewController = MainViewController()
            let coordinator = MainViewCoordinator(provider: provider, rootViewController: viewController)
            
            // DI
            viewController.coordinator = coordinator
            
            // set tab bar view controller initial index
            viewController.selectedIndex = MainViewController.TabType.Productivity.rawValue
            return viewController
        }
    }
}
