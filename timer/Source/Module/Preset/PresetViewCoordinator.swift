//
//  PresetViewCoordinator.swift
//  timer
//
//  Created by JSilver on 2019/11/30.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class PresetViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum Route {
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
    func present(for route: Route) -> UIViewController? {
        return get(for: route)
    }
    
    func get(for route: Route) -> UIViewController? {
        return nil
    }
    
    // MARK: - private method
    // MARK: - public method
}
