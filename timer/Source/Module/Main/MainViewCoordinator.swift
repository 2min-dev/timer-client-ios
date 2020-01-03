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
        case .historyDetail(_):
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.pushViewController(presentingViewController, animated: animated)
            
        default:
            break
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .productivity:
            let dependency = ProductivityViewBuilder.Dependency(provider: provider)
            return ProductivityViewBuilder(with: dependency).build()
            
        case .local:
            let dependency = LocalTimeSetViewBuilder.Dependency(provider: provider)
            return LocalTimeSetViewBuilder(with: dependency).build()
            
        case .preset:
            let dependency = PresetViewBuilder.Dependency(provider: provider)
            return PresetViewBuilder(with: dependency).build()
            
        case let .historyDetail(history):
            let dependency = HistoryDetailViewBuilder.Dependency(provider: provider, history: history)
            return HistoryDetailViewBuilder(with: dependency).build()
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
