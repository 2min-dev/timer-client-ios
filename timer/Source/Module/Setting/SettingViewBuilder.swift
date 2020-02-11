//
//  SettingViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class SettingViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider
        
        let coordinator = SettingViewCoordinator(provider: provider)
        let reactor = SettingViewReactor(appService: provider.appService)
        let viewController = SettingViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
