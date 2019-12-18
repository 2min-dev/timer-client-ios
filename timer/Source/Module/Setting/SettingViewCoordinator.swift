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
        case .dismiss:
            dismiss?(presentingViewController, animated)
            
        case .noticeList,
             .alarmSetting,
             .countdownSetting,
             .teamInfo,
             .license:
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.pushViewController(presentingViewController, animated: animated)
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .dismiss:
            return (viewController, self)
            
        case .noticeList:
            let dependency = NoticeListViewBuilder.Dependency(provider: provider)
            return NoticeListViewBuilder(with: dependency).build()
            
        case .alarmSetting:
            let dependency = AlarmSettingViewBuilder.Dependency(provider: provider)
            return AlarmSettingViewBuilder(with: dependency).build()
            
        case .countdownSetting:
            let dependency = CountdownSettingViewBuilder.Dependency(provider: provider)
            return CountdownSettingViewBuilder(with: dependency).build()
            
        case .teamInfo:
            let dependency = TeamInfoViewBuilder.Dependency(provider: provider)
            return TeamInfoViewBuilder(with: dependency).build()
            
        case .license:
            let dependency = OpenSourceLicenseViewBuilder.Dependency(provider: provider)
            return OpenSourceLicenseViewBuilder(with: dependency).build()
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
