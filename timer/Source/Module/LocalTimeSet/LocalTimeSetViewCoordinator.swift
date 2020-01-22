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
        case productivity
        case timeSetManage
        case allTimeSet
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
    func present(for route: Route, animated: Bool) -> UIViewController? {
        guard case (let controller, var coordinator)? = get(for: route) else { return nil }
        let presentingViewController = controller
        
        switch route {
        case .productivity:
            guard let mainViewController = presentingViewController.tabBarController as? MainViewController else { return nil }
            mainViewController.select(tab: .productivity, animated: animated)
            
        case .timeSetManage:
            // Set dismiss handler
            coordinator.dismiss = dismissViewController
            viewController.present(presentingViewController, animated: animated)
             
        case .allTimeSet,
             .timeSetDetail,
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
        case .productivity:
            return (viewController, self)
            
        case .timeSetManage:
            let dependency = TimeSetManageViewBuilder.Dependency(provider: provider)
            return TimeSetManageViewBuilder(with: dependency).build()
            
        case .allTimeSet:
            let dependency = AllTimeSetViewBuilder.Dependency(provider: provider)
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
