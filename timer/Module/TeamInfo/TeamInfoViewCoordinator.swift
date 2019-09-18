//
//  TeamInfoViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from app info view
class TeamInfoViewCoordinator: CoordinatorProtocol {
     // MARK: - route enumeration
    enum TeamInfoRoute {
        case empty
    }
    
	// MARK: - properties
	weak var viewController: TeamInfoViewController!
	let provider: ServiceProviderProtocol

    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
		self.provider = provider
	}

	func present(for route: TeamInfoRoute) -> UIViewController? {
        return get(for: route)
	}
    
    func get(for route: TeamInfoRoute) -> UIViewController? {
        return nil
    }
} 
