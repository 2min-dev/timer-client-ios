//
//  LocalTimeSetViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

/// Route from local time set view
class LocalTimeSetViewCoordinator: CoordinatorProtocol {
     // MARK: route enumeration
    enum LocalTimeSetRoute {
        
    }
    
    // MARK: properties
    weak var rootViewController: LocalTimeSetViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: LocalTimeSetViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    func present(for route: LocalTimeSetRoute) {
        
    }
}
