//
//  TimerOptionMainViewCoordinator.swift
//  timer
//
//  Created by JSilver on 25/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

class TimerOptionMainViewCoordinator {
    // MARK: - route enumeration
    enum Route {
        
    }
    
    // MARK: - properties
    weak var rootViewController: TimerOptionViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol, rootViewController: TimerOptionViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    // MARK: - presentation
    func present(for route: Route) {
        switch route {
            // Route code here
        }
    }
}
