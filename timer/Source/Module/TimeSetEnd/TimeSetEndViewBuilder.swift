//
//  TimeSetEndViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetEndViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
        let history: History
        let canSave: Bool
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider

        let coordinator = TimeSetEndViewCoordinator(provider: provider)
        let reactor = TimeSetEndViewReactor(historyService: provider.historyService, timeSetService: provider.timeSetService, logger: Logger(), history: dependency.history, canSave: dependency.canSave)
        let viewController = TimeSetEndViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
