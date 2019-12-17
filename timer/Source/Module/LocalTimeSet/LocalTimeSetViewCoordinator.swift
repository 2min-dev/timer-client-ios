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
    var dismiss: ((UIViewController, Bool) -> Void)?
    
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
            let dependency = TimeSetManageViewBuilder.Dependency(provider: provider, type: type)
            return TimeSetManageViewBuilder(with: dependency).build()
            
        case let .allTimeSet(type):
            let dependency = AllTimeSetViewBuilder.Dependency(provider: provider, type: type)
            return AllTimeSetViewBuilder(with: dependency).build()
            
        case let .timeSetDetail(timeSetItem):
            let dependency = TimeSetDetailViewBuilder.Dependency(provider: provider, timeSetItem: timeSetItem, canSave: false)
            return TimeSetDetailViewBuilder(with: dependency).build()

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
