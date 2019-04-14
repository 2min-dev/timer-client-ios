//
//  OneTouchTimerViewCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

/// Route from one touch timer view
class OneTouchTimerViewCoordinator: CoordinatorProtocl {
     // MARK: route enumeration
    enum OneTouchTimerRoute {
        
    }

    // MARK: properties
    weak var rootViewController: OneTouchTimerViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: OneTouchTimerViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    func present(for route: OneTouchTimerRoute) {
        
    }
}
