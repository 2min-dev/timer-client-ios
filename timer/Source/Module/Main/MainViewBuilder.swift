//
//  MainViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class MainViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider
        
        let coordinator = MainViewCoordinator(provider: provider)
        let reactor = MainViewReactor(timeSetService: provider.timeSetService)
        let viewController = MainViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        // set tab bar view controller initial index
        viewController.select(at: MainViewController.TabType.productivity.rawValue, animated: false)
        
        return (viewController, coordinator)
    }
}
