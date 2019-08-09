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
        case appInfo
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
        case .appInfo:
            Logger.verbose("presenting app info view controller.")
            // push view controller
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: SettingRoute) -> UIViewController? {
        switch route {
        case .appInfo:
            let coordinator = AppInfoCoordinator(provider: provider)
            let viewController = AppInfoViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = AppInfoViewReactor()
            
            return viewController
        }
    }
}
