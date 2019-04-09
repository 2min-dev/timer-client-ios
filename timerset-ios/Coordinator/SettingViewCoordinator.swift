//
//  SettingCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

enum SettingRoute {
    
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
        
    }
}
