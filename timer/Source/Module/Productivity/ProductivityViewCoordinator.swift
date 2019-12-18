//
//  ProductivityViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from one touch timer view
class ProductivityViewCoordinator: ViewCoordinator, ServiceContainer {
     // MARK: - route enumeration
    enum Route {
        case timeSetSave(TimeSetItem)
        case timeSetProcess(TimeSetItem)
        case history
        case setting
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
        case .timeSetSave(_),
             .timeSetProcess(_),
             .history,
             .setting:
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.pushViewController(presentingViewController, animated: animated)
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case let .timeSetSave(timeSetItem):
            let dependency = TimeSetSaveViewBuilder.Dependency(provider: provider, timeSetItem: timeSetItem)
            return TimeSetSaveViewBuilder(with: dependency).build()
            
        case let .timeSetProcess(timeSetItem):
            let dependency = TimeSetProcessViewBuilder.Dependency(provider: provider, timeSetItem: timeSetItem, canSave: true)
            return TimeSetProcessViewBuilder(with: dependency).build()
            
        case .history:
            let dependency = HistoryListViewBuilder.Dependency(provider: provider)
            return HistoryListViewBuilder(with: dependency).build()
            
        case .setting:
            let dependency = SettingViewBuilder.Dependency(provider: provider)
            return SettingViewBuilder(with: dependency).build()
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
