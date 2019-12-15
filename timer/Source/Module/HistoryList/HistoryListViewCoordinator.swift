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
        case productivity
        case detail(History)
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
        case .productivity:
            guard let mainViewController = viewController.navigationController?.viewControllers.first as? MainViewController else { return nil }
            // Select productivity tab
            mainViewController.select(at: MainViewController.TabType.productivity.rawValue, animated: false)
            viewController.navigationController?.setViewControllers([mainViewController], animated: true)
            
        case .detail:
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.pushViewController(presentingViewController, animated: true)
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .productivity:
            return (viewController, self)
            
        case let .detail(history):
            let coordinator = HistoryDetailViewCoordinator(provider: provider)
            guard let reactor = HistoryDetailViewReactor(timeSetService: provider.timeSetService, history: history) else { return nil }
            let viewController = HistoryDetailViewController(coordinator: coordinator)
            
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
