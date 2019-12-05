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
    enum Route {
        case timeSetSave(TimeSetItem)
        case timeSetProcess(TimeSetItem)
        case history
        case setting
    }

    // MARK: - properties
    weak var viewController: ProductivityViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func present(for route: Route) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .timeSetSave(_),
             .timeSetProcess(_),
             .history,
             .setting:
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case let .timeSetSave(timeSetItem):
            let coordinator = TimeSetSaveViewCoordinator(provider: provider)
            let reactor = TimeSetSaveViewReactor(timeSetService: provider.timeSetService, timeSetItem: timeSetItem)
            let viewController = TimeSetSaveViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case let .timeSetProcess(timeSetItem):
            let coordinator = TimeSetProcessViewCoordinator(provider: provider)
            guard let reactor = TimeSetProcessViewReactor(appService: provider.appService, timeSetService: provider.timeSetService, timeSetItem: timeSetItem, canSave: true) else { return nil }
            let viewController = TimeSetProcessViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case .history:
            let coordinator = HistoryListViewCoordinator(provider: provider)
            let reactor = HistoryListViewReactor(timeSetService: provider.timeSetService)
            let viewController = HistoryListViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case .setting:
            let coordinator = SettingViewCoordinator(provider: provider)
            let reactor = SettingViewReactor(appService: provider.appService, networkService: provider.networkService)
            let viewController = SettingViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
