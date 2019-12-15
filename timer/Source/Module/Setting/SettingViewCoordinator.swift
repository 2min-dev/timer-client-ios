//
//  SettingCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from setting view
class SettingViewCoordinator: ViewCoordinator, ServiceContainer {
     // MARK: - route enumeration
    enum Route {
        case dismiss
        case noticeList
        case alarmSetting
        case countdownSetting
        case teamInfo
        case license
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
        case .dismiss:
            dismiss?(presentingViewController)
            
        case .noticeList,
             .alarmSetting,
             .countdownSetting,
             .teamInfo,
             .license:
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.pushViewController(presentingViewController, animated: true)
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .dismiss:
            return (viewController, self)
            
        case .noticeList:
            let coordinator = NoticeListViewCoordinator(provider: provider)
            let reactor = NoticeListViewReactor(networkService: provider.networkService)
            let viewController = NoticeListViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case .alarmSetting:
            let coordinator = AlarmSettingViewCoordinator(provider: provider)
            let reactor = AlarmSettingViewReactor(appService: provider.appService)
            let viewController = AlarmSettingViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case .countdownSetting:
            let coordinator = CountdownSettingViewCoordinator(provider: provider)
            let reactor = CountdownSettingViewReactor(appService: provider.appService)
            let viewController = CountdownSettingViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case .teamInfo:
            let coordinator = TeamInfoViewCoordinator(provider: provider)
            let reactor = TeamInfoViewReactor()
            let viewController = TeamInfoViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case .license:
            let coordinator = OpenSourceLicenseViewCoordinator(provider: provider)
            let reactor = OpenSourceLicenseViewReactor()
            let viewController = OpenSourceLicenseViewController(coordinator: coordinator)
            
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
