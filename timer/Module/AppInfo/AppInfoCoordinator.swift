//
//  AppInfoCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from app info view
class AppInfoCoordinator: CoordinatorProtocol {
     // MARK: - route enumeration
    enum AppInfoRoute {
        
    }
    
	// MARK: - properties
	weak var viewController: AppInfoViewController!
	let provider: ServiceProviderProtocol

    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
		self.provider = provider
	}

	func present(for route: AppInfoRoute) -> UIViewController {
        let viewController = get(for: route)
        
        return viewController
	}
    
    func get(for route: AppInfoRoute) -> UIViewController {
        return UIViewController()
    }
} 
