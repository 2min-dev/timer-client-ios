//
//  LocalTimeSetViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from local time set view
class LocalTimeSetViewCoordinator: ViewCoordinator, ServiceContainer {
     // MARK: - route enumeration
    enum Route {
        case timeSetManage(TimeSetManageViewReactor.TimeSetType)
        case allTimeSet(AllTimeSetViewReactor.TimeSetType)
        case timeSetDetail(TimeSetItem)
        case history
        case setting
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
        case .timeSetManage(_):
            // Set dismiss handler
            coordinator.dismiss = dismissViewController
            viewController.present(presentingViewController, animated: true)
             
        case .allTimeSet(_),
             .timeSetDetail(_),
             .history,
             .setting:
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.pushViewController(presentingViewController, animated: true)
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case let .timeSetManage(type):
            let coordinator = TimeSetManageViewCoordinator(provider: provider)
            let reactor = TimeSetManageViewReactor(timeSetService: provider.timeSetService, type: type)
            let viewController = TimeSetManageViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case let .allTimeSet(type):
            let coordinator = AllTimeSetViewCoordinator(provider: provider)
            let reactor = AllTimeSetViewReactor(timeSetService: provider.timeSetService, type: type)
            let viewController = AllTimeSetViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case let .timeSetDetail(timeSetItem):
            let coordinator = TimeSetDetailViewCoordinator(provider: provider)
            let reactor = TimeSetDetailViewReactor(timeSetService: provider.timeSetService, timeSetItem: timeSetItem, canSave: false)
            let viewController = TimeSetDetailViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)

        case .history:
            let coordinator = HistoryListViewCoordinator(provider: provider)
            let reactor = HistoryListViewReactor(timeSetService: provider.timeSetService)
            let viewController = HistoryListViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case .setting:
            let coordinator = SettingViewCoordinator(provider: provider)
            let reactor = SettingViewReactor(appService: provider.appService, networkService: provider.networkService)
            let viewController = SettingViewController(coordinator: coordinator)
            
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
