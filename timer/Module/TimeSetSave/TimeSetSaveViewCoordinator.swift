//
//  TimeSetSaveViewCoordinator.swift
//  timer
//
//  Created by JSilver on 31/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetSaveViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum TimeSetSaveRoute {
        case timerOption
    }
    
    // MARK: - properties
    weak var viewController: TimeSetSaveViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: TimeSetSaveRoute) -> UIViewController {
        let viewController = get(for: route)
        return viewController
    }
    
    func get(for route: TimeSetSaveRoute) -> UIViewController {
        switch route {
        case .timerOption:
            let coordinator = TimerOptionViewCoordinator(provider: provider)
            let reactor = TimerOptionViewReactor()
            let viewController = TimerOptionViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.isNavigationBarHidden = true
            
            return navigationController
        }
    }
}
