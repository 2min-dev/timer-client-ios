//
//  AppInfoCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

/// Route from app info view
class AppInfoCoordinator: CoordinatorProtocol {
     // MARK: route enumeration
    enum AppInfoRoute {
        
    }
    
	// MARK: properties
	weak var rootViewController: AppInfoViewController!
	let provider: ServiceProviderProtocol

    required init(provider: ServiceProviderProtocol, rootViewController: AppInfoViewController) {
		self.provider = provider
        self.rootViewController = rootViewController
	}

	func present(for route: AppInfoRoute) {

	}
} 
