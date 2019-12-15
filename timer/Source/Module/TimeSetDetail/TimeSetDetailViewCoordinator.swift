//
//  TimeSetDetailViewCoordinator.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetDetailViewCoordinator: ViewCoordinator, ServiceContainer {
    // MARK: - route enumeration
    enum Route {
        case dismiss
        case timeSetEdit(TimeSetItem)
        case timeSetProcess(TimeSetItem, startAt: Int, canSave: Bool)
    }
    
    // MARK: - properties
    unowned var viewController: UIViewController!
    var dismiss: ((UIViewController) -> Void)?
    
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    @discardableResult
    func present(for route: Route) -> UIViewController? {
        guard case (let controller, var coordinator)? = get(for: route) else { return nil }
        let presentingViewController = controller
        
        switch route {
        case .dismiss:
            dismiss?(presentingViewController)
            
        case .timeSetEdit(_):
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.pushViewController(presentingViewController, animated: true)
            
        case .timeSetProcess(_, startAt: _, canSave: _):
            guard let mainViewController = viewController.navigationController?.viewControllers.first else { return nil }
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.setViewControllers([mainViewController, presentingViewController], animated: true)
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .dismiss:
            return (viewController, self)
            
        case let .timeSetEdit(timeSetItem):
            let coordinator = TimeSetEditViewCoordinator(provider: provider)
            guard let reactor = TimeSetEditViewReactor(appService: provider.appService, timeSetService: provider.timeSetService, timeSetItem: timeSetItem) else { return nil }
            let viewController = TimeSetEditViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case let .timeSetProcess(timeSetItem, startAt: index, canSave: canSave):
            let coordinator = TimeSetProcessViewCoordinator(provider: provider)
            guard let reactor = TimeSetProcessViewReactor(appService: provider.appService, timeSetService: provider.timeSetService, timeSetItem: timeSetItem, startIndex: index, canSave: canSave) else { return nil }
            let viewController = TimeSetProcessViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
