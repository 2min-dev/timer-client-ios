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
     // MARK: - route enumeration
    enum Route {
        case main
    }
    
    // MARK: - properties
    weak var viewController: IntroViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func present(for route: Route) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .main:
            // Present main view
            self.viewController.navigationController?.viewControllers = [viewController]
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case .main:
            let coordinator = MainViewCoordinator(provider: provider)
            let reactor = MainViewReactor(timeSetService: provider.timeSetService)
            let viewController = MainViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            
            // set tab bar view controller initial index
            viewController.select(at: MainViewController.TabType.productivity.rawValue, animated: false)
            return viewController
        }
    }
}
