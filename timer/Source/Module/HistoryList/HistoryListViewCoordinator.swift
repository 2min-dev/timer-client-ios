//
//  HistoryListViewCoordinator.swift
//  timer
//
//  Created by JSilver on 2019/10/13.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class HistoryListViewCoordinator: ViewCoordinator, ServiceContainer {
    // MARK: - route enumeration
    enum Route {
        case dismiss
        case productivity
        case detail(History)
    }
    
    // MARK: - properties
    unowned var viewController: UIViewController!
    var dismiss: ((UIViewController, Bool) -> Void)?
    
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    @discardableResult
    func present(for route: Route, animated: Bool) -> UIViewController? {
        guard case (let controller, var coordinator)? = get(for: route) else { return nil }
        let presentingViewController = controller
        
        switch route {
        case .dismiss:
            dismiss?(presentingViewController, animated)
            
        case .productivity:
            guard let mainViewController = viewController.navigationController?.viewControllers.first as? MainViewController else { return nil }
            // Select productivity tab
            mainViewController.select(at: MainViewController.TabType.productivity.rawValue, animated: false)
            viewController.navigationController?.setViewControllers([mainViewController], animated: animated)
            
        case .detail:
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.pushViewController(presentingViewController, animated: animated)
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .dismiss:
            return (viewController, self)
            
        case .productivity:
            return (viewController, self)
            
        case let .detail(history):
            let dependency = HistoryDetailViewBuilder.Dependency(provider: provider, history: history)
            return HistoryDetailViewBuilder(with: dependency).build()
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
