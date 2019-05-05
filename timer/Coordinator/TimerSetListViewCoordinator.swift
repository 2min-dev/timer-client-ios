//
//  TimerSetCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

/// Route from timer set view
class TimerSetListViewCoordinator: CoordinatorProtocol {
     // MARK: route enumeration
    enum TimerSetRoute {
        
    }
    
    // MARK: properties
    weak var rootViewController: TimerSetListViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: TimerSetListViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    func present(for route: TimerSetRoute) {
        
    }
}
