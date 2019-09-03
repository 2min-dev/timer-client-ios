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
    enum TimeSetProcessRoute {
        case home
        case timeSetProcess(TimeSetInfo)
        case timeSetMemo(TimeSet, origin: TimeSetInfo)
    }
    
    // MARK: - properties
    weak var viewController: TimeSetProcessViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: TimeSetProcessRoute) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        // Set enable that navigation controller pop gesture recognizer before present
        self.viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        switch route {
        case .home:
            self.viewController.navigationController?.setViewControllers([viewController], animated: true)
        
        case .timeSetProcess(_):
            guard let rootViewController = self.viewController.navigationController?.viewControllers.first else {
                return nil
            }
            let viewControllers = [rootViewController, viewController]
            self.viewController.navigationController?.setViewControllers(viewControllers, animated: true)
            
        case .timeSetMemo(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: TimeSetProcessRoute) -> UIViewController? {
        switch route {
        case .home:
            return self.viewController.navigationController?.viewControllers.first
            
        case let .timeSetProcess(timeSetInfo):
            let coordinator = TimeSetProcessViewCoordinator(provider: provider)
            guard let reactor = TimeSetProcessViewReactor(appService: provider.appService, timeSetService: provider.timeSetService, timeSetInfo: timeSetInfo) else { return nil }
            let viewController = TimeSetProcessViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case let .timeSetMemo(timeSet, origin: info):
            let coordinator = TimeSetMemoViewCoordinator(provider: provider)
            let reactor = TimeSetMemoViewReactor(timeSet: timeSet, origin: info)
            let viewController = TimeSetMemoViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
