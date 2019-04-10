//
//  RootCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

class RootViewCoordinator {
    let rootViewController: RootViewController
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.rootViewController = RootViewController()
        self.provider = provider
        
        // DI
        self.rootViewController.coordinator = self
    }
}
