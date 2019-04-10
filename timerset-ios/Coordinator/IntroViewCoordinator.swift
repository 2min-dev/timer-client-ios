//
//  IntroCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

enum IntroRoute {
    case timerSet
}

/// Route from Intro view
class IntroViewCoordinator {
    // MARK: properties
    let rootViewController: IntroViewController
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.rootViewController = IntroViewController()
        self.provider = provider
        
        // DI
        self.rootViewController.coordinator = self
        self.rootViewController.reactor = IntroViewReactor()
    }
    
    func present(for route: IntroRoute) {
        switch route {
        case .timerSet:
            let coordinator = MainViewCoordinator(provider: provider)
            let viewController = coordinator.rootViewController
            
            // set tab bar view controller initial index
            viewController.selectedIndex = 1
            
            // present view
            rootViewController.navigationController?.viewControllers = [viewController]
        }
    }
}
