//
//  PresetViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class PresetViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider
        
        let coordinator = PresetViewCoordinator(provider: provider)
        let reactor = PresetViewReactor(networkService: provider.networkService)
        let viewController = PresetViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
