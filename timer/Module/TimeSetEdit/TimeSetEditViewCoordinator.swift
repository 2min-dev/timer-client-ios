//
//  TimeSetEditViewCoordinator.swift
//  timer
//
//  Created by JSilver on 09/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetEditViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum TimeSetEditRoute {
        case empty
    }
    
    // MARK: - properties
    weak var viewController: TimeSetEditViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: TimeSetEditRoute) -> UIViewController? {
        return get(for: route)
    }
    
    func get(for route: TimeSetEditRoute) -> UIViewController? {
        return nil
    }
    
    // MARK: - private method
    // MARK: - public method
}
