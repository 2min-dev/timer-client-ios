//
//  OneTouchTimerViewCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

enum OneTouchTimerRoute {

}

class OneTouchTimerViewCoordinator {
    // MARK: properties
    let rootViewController: OneTouchTimerViewController
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.rootViewController = OneTouchTimerViewController()
        self.provider = provider
        
        // DI
        self.rootViewController.coordinator = self
        self.rootViewController.reactor = OneTouchTimerViewReactor()
    }
    
    func present(for route: OneTouchTimerRoute) {
        
    }
}
