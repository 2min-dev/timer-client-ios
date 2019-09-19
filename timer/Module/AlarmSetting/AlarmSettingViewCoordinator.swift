//
//  AlarmSettingViewCoordinator.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class AlarmSettingViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum AlarmSettingRoute {
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
    func present(for route: AlarmSettingRoute) -> UIViewController? {
        return get(for: route)
    }
    
    func get(for route: AlarmSettingRoute) -> UIViewController? {
        return nil
    }
    
    // MARK: - private method
    // MARK: - public method
}
