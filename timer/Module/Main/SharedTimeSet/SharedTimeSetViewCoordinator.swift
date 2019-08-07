//
//  SharedTimeSetViewCoordinator.swift
//  timer
//
//  Created by JSilver on 2019/07/06.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from shread time set view
class SharedTimeSetViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum ShraedTimeSetRoute {
        case intro
    }
    
    // MARK: - properties
    weak var viewController: SharedTimeSetViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func present(for route: ShraedTimeSetRoute) -> UIViewController? {
        return get(for: route)
    }
    
    func get(for route: ShraedTimeSetRoute) -> UIViewController? {
        return nil
    }
}
