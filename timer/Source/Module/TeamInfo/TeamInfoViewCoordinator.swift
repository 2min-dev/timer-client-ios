//
//  TeamInfoViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TeamInfoViewCoordinator: ViewCoordinator, ServiceContainer {
     // MARK: - route enumeration
    enum Route {
        case dismiss
    }
    
	// MARK: - properties
	unowned var viewController: UIViewController!
    var dismiss: ((UIViewController) -> Void)?
    
	let provider: ServiceProviderProtocol

    // MARK: - constructor
    init(provider: ServiceProviderProtocol) {
		self.provider = provider
	}

    // MARK: - presentation
    @discardableResult
	func present(for route: Route) -> UIViewController? {
        guard case (let controller, _)? = get(for: route) else { return nil }
        let presentingViewController = controller
        
        switch route {
        case .dismiss:
            dismiss?(presentingViewController)
        }
        
        return controller
	}
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .dismiss:
            return (viewController, self)
        }
    }
    
    deinit {
        Logger.verbose()
    }
} 
