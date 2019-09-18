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
    enum SettingRoute {
        case notice
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
    
    func present(for route: SettingRoute) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .teamInfo:
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
            
        default:
            break
        }
        
        return viewController
    }
    
    func get(for route: SettingRoute) -> UIViewController? {
        switch route {
        case .teamInfo:
            let coordinator = AppInfoCoordinator(provider: provider)
            let viewController = AppInfoViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = AppInfoViewReactor()
            
            return viewController

        default:
            return nil
        }
    }
}
