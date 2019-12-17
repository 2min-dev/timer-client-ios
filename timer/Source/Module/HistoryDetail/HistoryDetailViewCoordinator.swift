//
//  HistoryDetailViewCoordinator.swift
//  timer
//
//  Created by JSilver on 2019/10/15.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class HistoryDetailViewCoordinator: ViewCoordinator, ServiceContainer {
    // MARK: - route enumeration
    enum Route {
        case dismiss
        case timeSetEdit(TimeSetItem)
        case timeSetProcess(TimeSetItem)
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
            
        case .timeSetProcess(_):
            guard let mainViewController = viewController.navigationController?.viewControllers.first else { return nil }
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.setViewControllers([mainViewController, presentingViewController], animated: true)
            
        case .timeSetEdit(_):
            // Set dismiss handler
            coordinator.dismiss = popViewController
            self.viewController.navigationController?.pushViewController(presentingViewController, animated: true)
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .dismiss:
            return (viewController, self)
            
        case let .timeSetEdit(timeSetItem):
            let dependency = TimeSetEditViewBuilder.Dependency(provider: provider, timeSetItem: timeSetItem)
            return TimeSetEditViewBuilder(with: dependency).build()
            
        case let .timeSetProcess(timeSetItem):
            let dependency = TimeSetProcessViewBuilder.Dependency(provider: provider, timeSetItem: timeSetItem, startIndex: nil, canSave: true)
            return TimeSetProcessViewBuilder(with: dependency).build()
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
