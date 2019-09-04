//
//  ProductivityViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from one touch timer view
class ProductivityViewCoordinator: CoordinatorProtocol {
     // MARK: - route enumeration
    enum ProductivityRoute {
        case timerOption
        case timeSetSave(TimeSetInfo)
        case timeSetProcess(TimeSetInfo?)
    }

    // MARK: - properties
    weak var viewController: ProductivityViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func present(for route: ProductivityRoute) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .timeSetSave(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
            
        case .timeSetProcess(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
            
        default:
            break
        }
        
        return viewController
    }
    
    func get(for route: ProductivityRoute) -> UIViewController? {
        switch route {
        case .timerOption:
            let coordinator = TimerOptionViewCoordinator(provider: provider)
            let reactor = TimerOptionViewReactor()
            let viewController = TimerOptionViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.isNavigationBarHidden = true
            
            return navigationController
            
        case let .timeSetSave(timeSetInfo):
            let coordinator = TimeSetSaveViewCoordinator(provider: provider)
            let reactor = TimeSetSaveViewReactor(timeSetService: provider.timeSetService, timeSetInfo: timeSetInfo)
            let viewController = TimeSetSaveViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case let .timeSetProcess(timeSetInfo):
            let coordinator = TimeSetProcessViewCoordinator(provider: provider)
            guard let reactor = TimeSetProcessViewReactor(appService: provider.appService, timeSetService: provider.timeSetService, timeSetInfo: timeSetInfo) else { return nil }
            let viewController = TimeSetProcessViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
