//
//  TimeSetEditViewCoordinator.swift
//  timer
//
//  Created by JSilver on 31/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetEditViewCoordinator: CoordinatorProtocol {
    
    // MARK: - route enumeration
    enum Route {
        
    }
    
    // MARK: - properties
    weak var rootViewController: TimeSetEditViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol, rootViewController: TimeSetEditViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    // MARK: - presentation
    func present(for route: Route) -> UIViewController {
        let viewController = get(for: route)
        return viewController
    }
    
    func get(for route: Route) -> UIViewController {
        return UIViewController()
    }
}
