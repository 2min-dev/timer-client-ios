//
//  AllTimeSetViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class AllTimeSetViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
        let type: AllTimeSetViewReactor.TimeSetType
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider
        
        let coordinator = AllTimeSetViewCoordinator(provider: provider)
        let reactor = AllTimeSetViewReactor(timeSetService: provider.timeSetService, networkService: provider.networkService, type: dependency.type)
        let viewController = AllTimeSetViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
