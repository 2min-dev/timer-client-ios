//
//  SettingCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from setting view
class SettingViewCoordinator: CoordinatorProtocol {
     // MARK: - route enumeration
    enum Route {
        case noticeList
        case alarmSetting
        case countdownSetting
        case teamInfo
        case license
    }
    
    // MARK: - properties
    weak var viewController: SettingViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func present(for route: Route) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .noticeList,
             .alarmSetting,
             .countdownSetting,
             .teamInfo,
             .license:
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case .noticeList:
            let coordinator = NoticeListViewCoordinator(provider: provider)
            let reactor = NoticeListViewReactor()
            let viewController = NoticeListViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case .alarmSetting:
            let coordinator = AlarmSettingViewCoordinator(provider: provider)
            let reactor = AlarmSettingViewReactor(appService: provider.appService)
            let viewController = AlarmSettingViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case .countdownSetting:
            let coordinator = CountdownSettingViewCoordinator(provider: provider)
            let reactor = CountdownSettingViewReactor(appService: provider.appService)
            let viewController = CountdownSettingViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case .teamInfo:
            let coordinator = TeamInfoViewCoordinator(provider: provider)
            let reactor = TeamInfoViewReactor()
            let viewController = TeamInfoViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case .license:
            let coordinator = OpenSourceLicenseViewCoordinator(provider: provider)
            let reactor = OpenSourceLicenseViewReactor()
            let viewController = OpenSourceLicenseViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
