//
//  TimeSetEditViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetEditViewBuilder: Builder {
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
        
        let coordinator = TimeSetEditViewCoordinator(provider: provider)
        guard let reactor = TimeSetEditViewReactor(appService: provider.appService, timeSetService: provider.timeSetService, timeSetItem: dependency.timeSetItem) else { return nil }
        let viewController = TimeSetEditViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
