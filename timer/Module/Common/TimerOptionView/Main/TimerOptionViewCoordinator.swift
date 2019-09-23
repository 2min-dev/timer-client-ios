//
//  TimerOptionViewCoordinator.swift
//  timer
//
//  Created by JSilver on 25/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimerOptionViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum Route {
        case empty
    }
    
    // MARK: - properties
    weak var viewController: TimerOptionViewController!
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
}
