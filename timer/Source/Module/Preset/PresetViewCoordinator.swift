//
//  PresetViewCoordinator.swift
//  timer
//
//  Created by JSilver on 2019/11/30.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class PresetViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum Route {
        case timeSetDetail(TimeSetItem)
        case history
        case setting
    }
    
    // MARK: - properties
    weak var viewController: UIViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: Route) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .timeSetDetail(_),
             .history,
             .setting:
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case let .timeSetDetail(timeSetItem):
            let coordinator = TimeSetDetailViewCoordinator(provider: provider)
            let reactor = TimeSetDetailViewReactor(timeSetService: provider.timeSetService, timeSetItem: timeSetItem)
            let viewController = TimeSetDetailViewController(coordinator: coordinator)
            
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
