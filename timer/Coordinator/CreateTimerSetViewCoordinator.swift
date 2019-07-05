//
//  CreateTimerSetViewCoordinator.swift
//  timer
//
//  Created by JSilver on 19/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class CreateTimerSetViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum CreateTimerSetRoute {
        case intro
    }
    
    // MARK: - properties
    weak var rootViewController: CreateTimerSetViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: CreateTimerSetViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    func present(for route: CreateTimerSetRoute) {
        
    }
}
