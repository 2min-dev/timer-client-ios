//
//  MainViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from main view (tab bar)
class MainViewCoordinator: CoordinatorProtocol {
     // MARK: route enumeration
    enum MainRoute {
        
    }
    
    weak var rootViewController: MainViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: MainViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
        
        // tab bar controller initialize
        let productivityViewController = ProductivityViewController()
        let productivityViewCoordinator = ProductivityViewCoordinator(provider: provider, rootViewController: productivityViewController)
        let productivityViewReactor = ProductivityViewReactor(timerService: provider.timerService)
        
        let localViewController = LocalTimeSetViewController()
        let localViewCoordinator = LocalTimeSetViewCoordinator(provider: provider, rootViewController: localViewController)
        let localViewReactor = LocalTimeSetViewReactor()
        
        let shareViewController = SharedTimeSetViewController()
        let shareViewCoordinator = SharedTimeSetViewCoordinator(provider: provider, rootViewController: shareViewController)
        let shareViewReactor = SharedTimeSetViewReactor()
        
        // DI
        productivityViewController.coordinator = productivityViewCoordinator
        productivityViewController.reactor = productivityViewReactor
        
        localViewController.coordinator = localViewCoordinator
        localViewController.reactor = localViewReactor
        
        shareViewController.coordinator = shareViewCoordinator
        shareViewController.reactor = shareViewReactor
        
        // Set tab bar items
        self.rootViewController._tabBar.tabBarItems = [
            TMTabBarItem(title: "tab_button_local_time_set".localized, icon: UIImage(named: "local")),
            TMTabBarItem(title: "tab_button_home".localized, icon: UIImage(named: "home")),
            TMTabBarItem(title: "tab_button_shared_time_set".localized, icon: UIImage(named: "share"))
        ]
        
        // Set view controllers
        self.rootViewController.viewControllers = [localViewController, productivityViewController, shareViewController]
    }
    
    func present(for route: MainRoute) -> UIViewController {
        let viewController = get(for: route)
        
        return viewController
    }
    
    func get(for route: MainRoute) -> UIViewController {
        return UIViewController()
    }
}
