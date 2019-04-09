//
//  AppCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

enum AppRoute {
    case intro
}

/// Route from app initialze
class AppCoordinator {
    // MARK: properties
    let window: UIWindow
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol, window: UIWindow) {
        self.provider = provider
        self.window = window
    }
    
    func present(for route: AppRoute) {
        switch route {
        case .intro:
            // initialize view
            let coordinator: IntroViewCoordinator = IntroViewCoordinator(provider: self.provider)
            let viewController: IntroViewController = coordinator.rootViewController
            
            // present view
            self.window.rootViewController = viewController
            self.window.makeKeyAndVisible()
        }
    }
}
