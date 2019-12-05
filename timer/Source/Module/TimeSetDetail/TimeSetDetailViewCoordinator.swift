//
//  TimeSetDetailViewCoordinator.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetDetailViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum Route {
        case home
        case timeSetEdit(TimeSetItem)
        case timeSetProcess(TimeSetItem, startAt: Int, canSave: Bool)
    }
    
    // MARK: - properties
    weak var viewController: TimeSetDetailViewController!
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
            self.viewController.navigationController?.setViewControllers([viewController], animated: true)
            
        case .timeSetEdit(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
            
        case .timeSetProcess(_, startAt: _, canSave: _):
            guard let rootViewController = self.viewController.navigationController?.viewControllers.first else {
                return nil
            }
            let viewControllers = [rootViewController, viewController]
            self.viewController.navigationController?.setViewControllers(viewControllers, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case .home:
            return self.viewController.navigationController?.viewControllers.first
            
        case let .timeSetEdit(timeSetItem):
            let coordinator = TimeSetEditViewCoordinator(provider: provider)
            guard let reactor = TimeSetEditViewReactor(appService: provider.appService, timeSetService: provider.timeSetService, timeSetItem: timeSetItem) else { return nil }
            let viewController = TimeSetEditViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case let .timeSetProcess(timeSetItem, startAt: index, canSave: canSave):
            let coordinator = TimeSetProcessViewCoordinator(provider: provider)
            guard let reactor = TimeSetProcessViewReactor(appService: provider.appService, timeSetService: provider.timeSetService, timeSetItem: timeSetItem, startIndex: index, canSave: canSave) else { return nil }
            let viewController = TimeSetProcessViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
