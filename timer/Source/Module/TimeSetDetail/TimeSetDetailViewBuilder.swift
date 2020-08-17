//
//  TimeSetDetailViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetDetailViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
        let timeSetItem: TimeSetItem
        let type: TimeSetDetailViewReactor.TimeSetType
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider

        let coordinator = TimeSetDetailViewCoordinator(provider: provider)
        let reactor = TimeSetDetailViewReactor(timeSetService: provider.timeSetService, logger: Logger(), timeSetItem: dependency.timeSetItem, type: dependency.type)
        let viewController = TimeSetDetailViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
