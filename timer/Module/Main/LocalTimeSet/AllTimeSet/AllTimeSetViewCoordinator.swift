//
//  AllTimeSetViewCoordinator.swift
//  timer
//
//  Created by JSilver on 18/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class AllTimeSetViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum AllTimeSetRoute {
        case empty
    }
    
    // MARK: - properties
    weak var viewController: UIViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: AllTimeSetRoute) -> UIViewController? {
        return get(for: route)
    }
    
    func get(for route: AllTimeSetRoute) -> UIViewController? {
        return nil
    }
    
    // MARK: - private method
    // MARK: - public method
}
