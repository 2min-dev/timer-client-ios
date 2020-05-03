//
//  HistoryDetailViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class HistoryDetailViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
        let history: History
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider
        
        let coordinator = HistoryDetailViewCoordinator(provider: provider)
        guard let reactor = HistoryDetailViewReactor(historyService: provider.historyService, timeSetService: provider.timeSetService, logger: Logger(), history: dependency.history, canSave: true) else { return nil }
        let viewController = HistoryDetailViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
