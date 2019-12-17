//
//  NoticeDetailViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class NoticeDetailViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
        let notice: Notice
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider

        let coordinator = NoticeDetailViewCoordinator(provider: provider)
        let reactor = NoticeDetailViewReactor(networkService: provider.networkService, notice: dependency.notice)
        let viewController = NoticeDetailViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
