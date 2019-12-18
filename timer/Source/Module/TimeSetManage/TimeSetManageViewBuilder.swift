//
//  TimeSetManageViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetManageViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
        let type: TimeSetManageViewReactor.TimeSetType
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider
        
        let coordinator = TimeSetManageViewCoordinator(provider: provider)
        let reactor = TimeSetManageViewReactor(timeSetService: provider.timeSetService, type: dependency.type)
        let viewController = TimeSetManageViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
