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
        case timeSetProcess(TimeSetInfo)
        case timeSetMemo(TimeSetInfo)
        case timeSetEnd(TimeSetInfo)
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
            self.viewController.navigationController?.setViewControllers(viewControllers, animated: false)
            
        case .timeSetMemo(_):
            viewController.modalPresentationStyle = .fullScreen
            self.viewController.present(viewController, animated: true)
            
        case .timeSetEnd(_):
            viewController.modalPresentationStyle = .fullScreen
            self.viewController.present(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
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
            
        case let .timeSetMemo(timeSetInfo):
            let coordinator = TimeSetMemoViewCoordinator(provider: provider)
            let reactor = TimeSetMemoViewReactor(timeSetInfo: timeSetInfo)
            let viewController = TimeSetMemoViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case let .timeSetEnd(timeSetInfo):
            let coordinator = TimeSetEndViewCoordinator(provider: provider)
            let reactor = TimeSetEndViewReactor(timeSetInfo: timeSetInfo)
            let viewController = TimeSetEndViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
