//
//  TimeSetMemoViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetMemoViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
        let history: History
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider

        let coordinator = TimeSetMemoViewCoordinator(provider: provider)
        let reactor = TimeSetMemoViewReactor(history: dependency.history)
        let viewController = TimeSetMemoViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
