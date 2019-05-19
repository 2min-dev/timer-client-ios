//
//  RootCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

/// Route from root view (navigation)
class RootViewCoordinator: CoordinatorProtocol {
    // MARK: route enumeration
    enum RootRoute {
        
    }
    
    weak var rootViewController: RootViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: RootViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    func present(for route: RootRoute) {
        
    }
}
