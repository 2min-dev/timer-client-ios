//
//  MainViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from main view (tab bar)
class MainViewCoordinator: CoordinatorProtocol {
     // MARK: - route enumeration
    enum MainRoute {
        case productivity
        case local
        case share
    }
    
    weak var viewController: MainViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func present(for route: MainRoute) -> UIViewController? {
        return get(for: route)
    }
    
    func get(for route: MainRoute) -> UIViewController? {
        switch route {
        case .productivity:
            let coordinator = ProductivityViewCoordinator(provider: provider)
            let reactor = ProductivityViewReactor(timerService: provider.timerService)
            let viewController = ProductivityViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        case .local:
            let coordinator = LocalTimeSetViewCoordinator(provider: provider)
            let reactor = LocalTimeSetViewReactor()
            let viewController = LocalTimeSetViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        case .share:
            let coordinator = SharedTimeSetViewCoordinator(provider: provider)
            let reactor = SharedTimeSetViewReactor()
            let viewController = SharedTimeSetViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
