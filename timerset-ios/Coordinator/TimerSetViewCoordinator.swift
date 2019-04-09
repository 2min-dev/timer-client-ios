//
//  TimerSetCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

enum TimerSetRoute {
    
}

class TimerSetViewCoordinator {
    // MARK: properties
    let rootViewController: TimerSetViewController
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.rootViewController = TimerSetViewController()
        self.provider = provider
        
        // DI
        self.rootViewController.coordinator = self
        self.rootViewController.reactor = TimerSetViewReactor()
    }
    
    func present(for route: TimerSetRoute) {
        
    }
}
