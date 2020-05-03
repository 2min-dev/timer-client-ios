//
//  TimeSetSaveViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetSaveViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
        let timeSetItem: TimeSetItem
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider
        
        let coordinator = TimeSetSaveViewCoordinator(provider: provider)
        let reactor = TimeSetSaveViewReactor(timeSetService: provider.timeSetService, logger: Logger(), timeSetItem: dependency.timeSetItem)
        let viewController = TimeSetSaveViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
