//
//  LocalTimeSetViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from local time set view
class LocalTimeSetViewCoordinator: CoordinatorProtocol {
     // MARK: - route enumeration
    enum Route {
        case timeSetManage(TimeSetManageViewReactor.TimeSetType)
        case allTimeSet(AllTimeSetViewReactor.TimeSetType)
        case timeSetDetail(TimeSetInfo)
        case setting
    }
    
    // MARK: - properties
    weak var viewController: LocalTimeSetViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func present(for route: Route) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .timeSetManage(_),
             .allTimeSet(_),
             .timeSetDetail(_),
             .setting:
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case let .timeSetManage(type):
            let coordinator = TimeSetManageViewCoordinator(provider: provider)
            let reactor = TimeSetManageViewReactor(timeSetService: provider.timeSetService, type: type)
            let viewController = TimeSetManageViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case let .allTimeSet(type):
            let coordinator = AllTimeSetViewCoordinator(provider: provider)
            let reactor = AllTimeSetViewReactor(timeSetService: provider.timeSetService, type: type)
            let viewController = AllTimeSetViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case let .timeSetDetail(timeSetInfo):
            let coordinator = TimeSetDetailViewCoordinator(provider: provider)
            let reactor = TimeSetDetailViewReactor(timeSetService: provider.timeSetService, timeSetInfo: timeSetInfo)
            let viewController = TimeSetDetailViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case .setting:
            let coordinator = SettingViewCoordinator(provider: provider)
            let reactor = SettingViewReactor(appService: provider.appService)
            let viewController = SettingViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
