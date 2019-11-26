//
//  TimeSetEndViewCoordinator.swift
//  timer
//
//  Created by JSilver on 2019/10/09.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetEndViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum Route {
        case home
        case timeSetEdit(TimeSetItem)
    }
    
    // MARK: - properties
    weak var viewController: TimeSetEndViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: Route) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .home:
            guard let navigationController = self.viewController.presentingViewController as? UINavigationController else { return nil }
            navigationController.setViewControllers([viewController], animated: true)
            self.viewController.dismiss(animated: true)
            
        case .timeSetEdit(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case .home:
            guard let navigationController = self.viewController.presentingViewController as? UINavigationController else { return nil }
            return navigationController.viewControllers.first
            
        case let .timeSetEdit(timeSetItem):
            let coordinator = TimeSetEditViewCoordinator(provider: provider)
            guard let reactor = TimeSetEditViewReactor(appService: provider.appService, timeSetService: provider.timeSetService, timeSetItem: timeSetItem) else { return nil }
            let viewController = TimeSetEditViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
