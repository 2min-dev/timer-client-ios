//
//  SettingCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

enum SettingRoute {
    case appInfo
    
    case laboratory
}

class SettingViewCoordinator {
    // MARK: properties
    let rootViewController: SettingViewController
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.rootViewController = SettingViewController()
        self.provider = provider
        
        // DI
        self.rootViewController.coordinator = self
        self.rootViewController.reactor = SettingViewReactor()
    }
    
    func present(for route: SettingRoute) {
        switch route {
        case .appInfo:
            Logger.verbose("presenting app info view controller.")
            
            let coordinator = AppInfoCoordinator(provider: provider)
            let viewController = coordinator.rootViewController
            
            // push view controller
            rootViewController.navigationController?.pushViewController(viewController, animated: true)
        case .laboratory:
            Logger.verbose("presenting laboratory view controller.")
            
            // load `laboratory` view controller
            let storyboard = UIStoryboard(name: "laboratory", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LaboratoryViewController")
            
            // push view controller
            rootViewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
