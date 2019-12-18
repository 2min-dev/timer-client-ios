//
//  LocalTimeSetBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class LocalTimeSetViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider
        
        let coordinator = LocalTimeSetViewCoordinator(provider: provider)
        let reactor = LocalTimeSetViewReactor(timeSetService: provider.timeSetService)
        let viewController = LocalTimeSetViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
