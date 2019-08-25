//
//  TimeSetProcessViewCoordinator.swift
//  timer
//
//  Created by JSilver on 12/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetProcessViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum Route {
        case home
        case timeSetProcess(TimeSetInfo?, start: Int)
    }
    
    // MARK: - properties
    weak var viewController: TimeSetProcessViewController!
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
        
        case .timeSetProcess(_, start: _):
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
            
        case let .timeSetProcess(timeSetInfo, start: index):
            let coordinator = TimeSetProcessViewCoordinator(provider: provider)
            let reactor = TimeSetProcessViewReactor(appService: provider.appService, timeSetService: provider.timeSetService, timeSetInfo: timeSetInfo, start: index)
            let viewController = TimeSetProcessViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
