//
//  CountdownSettingViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class CountdownSettingViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider
        
        let coordinator = CountdownSettingViewCoordinator(provider: provider)
        let reactor = CountdownSettingViewReactor(appService: provider.appService)
        let viewController = CountdownSettingViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
