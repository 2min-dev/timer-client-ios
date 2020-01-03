//
//  TeamInfoViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TeamInfoViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider
        
        let coordinator = TeamInfoViewCoordinator(provider: provider)
        let reactor = TeamInfoViewReactor()
        let viewController = TeamInfoViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
