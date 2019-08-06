//
//  TimeSetDetailViewCoordinator.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetDetailViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum TimeSetDetailRoute {
        
    }
    
    // MARK: - properties
    weak var viewController: TimeSetDetailViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: TimeSetDetailRoute) -> UIViewController {
        let viewController = get(for: route)
        return viewController
    }
    
    func get(for route: TimeSetDetailRoute) -> UIViewController {
        return UIViewController()
    }
}
