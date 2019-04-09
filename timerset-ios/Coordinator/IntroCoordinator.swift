//
//  IntroCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

enum IntroRoute {
    case main
}

/// Route from Intro view
class IntroViewCoordinator: NSObject {
    // MARK: properties
    let rootViewController: IntroViewController
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.rootViewController = IntroViewController()
        self.provider = provider
        super.init()
        
        // DI
        self.rootViewController.coordinator = self
        self.rootViewController.reactor = IntroViewReactor()
    }
    
    func present(for route: IntroRoute) {
        switch route {
        case .main:
            Logger.verbose("implement route")
        }
    }
}
