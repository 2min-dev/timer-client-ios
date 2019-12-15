//
//  MainViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from main view (tab bar)
class MainViewCoordinator: ViewCoordinator, ServiceContainer {
     // MARK: - route enumeration
    enum Route {
        case productivity
        case local
        case preset
        case historyDetail(History)
    }
    
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
        case .historyDetail(_):
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.pushViewController(presentingViewController, animated: true)
            
        default:
            break
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .productivity:
            let coordinator = ProductivityViewCoordinator(provider: provider)
            let reactor = TimeSetEditViewReactor(appService: provider.appService, timeSetService: provider.timeSetService)
            let viewController = ProductivityViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case .local:
            let coordinator = LocalTimeSetViewCoordinator(provider: provider)
            let reactor = LocalTimeSetViewReactor(timeSetService: provider.timeSetService)
            let viewController = LocalTimeSetViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case .preset:
            let coordinator = PresetViewCoordinator(provider: provider)
            let reactor = PresetViewReactor(networkService: provider.networkService)
            let viewController = PresetViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case let .historyDetail(history):
            let coordinator = HistoryDetailViewCoordinator(provider: provider)
            let reactor = HistoryDetailViewReactor(timeSetService: provider.timeSetService, history: history)
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
