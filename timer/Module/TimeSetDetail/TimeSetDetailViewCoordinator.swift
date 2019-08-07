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
        case empty
    }
    
    // MARK: - properties
    weak var viewController: TimeSetDetailViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: TimeSetDetailRoute) -> UIViewController? {
        return get(for: route)
    }
    
    func get(for route: TimeSetDetailRoute) -> UIViewController? {
        return nil
    }
}
