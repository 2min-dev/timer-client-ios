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
    weak var rootViewController: SharedTimeSetViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: SharedTimeSetViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    func present(for route: ShraedTimeSetRoute) -> UIViewController {
        let viewController = get(for: route)
        
        return viewController
    }
    
    func get(for route: ShraedTimeSetRoute) -> UIViewController {
        return UIViewController()
    }
}
