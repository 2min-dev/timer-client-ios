//
//  SettingCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from setting view
class SettingViewCoordinator: CoordinatorProtocol {
     // MARK: route enumeration
    enum SettingRoute {
        case appInfo
        
        case laboratory
    }
    
    // MARK: properties
    weak var rootViewController: SettingViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: SettingViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    func present(for route: SettingRoute) {
        switch route {
        case .appInfo:
            Logger.verbose("presenting app info view controller.")
            
            let viewController = AppInfoViewController()
            let coordinator = AppInfoCoordinator(provider: provider, rootViewController: viewController)
            
            // DI
            viewController.coordinator = coordinator
            viewController.reactor = AppInfoViewReactor(appService: provider.appService)
            
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
