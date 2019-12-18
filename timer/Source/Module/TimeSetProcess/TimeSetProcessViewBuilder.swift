//
//  TimeSetProcessViewBuilder.swift
//  timer
//
//  Created by JSilver on 2019/12/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetProcessViewBuilder: Builder {
    struct Dependency {
        let provider: ServiceProviderProtocol
        let timeSetItem: TimeSetItem?
        let startIndex: Int?
        let canSave: Bool?
        
        init(provider: ServiceProviderProtocol, timeSetItem: TimeSetItem, startIndex: Int = 0, canSave: Bool) {
            self.provider = provider
            self.timeSetItem = timeSetItem
            self.startIndex = startIndex
            self.canSave = canSave
        }
        
        init(provider: ServiceProviderProtocol) {
            self.provider = provider
            self.timeSetItem = nil
            self.startIndex = nil
            self.canSave = nil
        }
    }
    
    var dependency: Dependency
    
    required init(with dependency: Dependency) {
        self.dependency = dependency
    }
    
    func build() -> (UIViewController, ViewCoordinatorType)? {
        let provider = dependency.provider

        let coordinator = TimeSetProcessViewCoordinator(provider: provider)
        let reactor: TimeSetProcessViewReactor
        if let timeSetItem = dependency.timeSetItem, let startIndex = dependency.startIndex, let canSave = dependency.canSave {
            guard let viewReactor = TimeSetProcessViewReactor(
                appService: provider.appService,
                timeSetService: provider.timeSetService,
                timeSetItem: timeSetItem,
                startIndex: startIndex,
                canSave: canSave
            ) else { return nil }
            reactor = viewReactor
        } else {
            guard let viewReactor = TimeSetProcessViewReactor(appService: provider.appService, timeSetService: provider.timeSetService) else { return nil }
            reactor = viewReactor
        }
        let viewController = TimeSetProcessViewController(coordinator: coordinator)
        
        // DI
        coordinator.viewController = viewController
        viewController.reactor = reactor
        
        return (viewController, coordinator)
    }
}
