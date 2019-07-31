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
        
        let productivityTabBarItem = UITabBarItem(title: "tab_button_home".localized, image: UIImage(named: "home"), tag: 0)
        productivityViewController.tabBarItem = productivityTabBarItem
        
        let localTabBarItem = UITabBarItem(title: "tab_button_local_time_set".localized, image: UIImage(named: "local"), tag: 0)
        localViewController.tabBarItem = localTabBarItem
        
        let shareTabBarItem = UITabBarItem(title: "tab_button_shared_time_set".localized, image: UIImage(named: "share"), tag: 0)
        shareViewController.tabBarItem = shareTabBarItem
        
        // Set tab bar item inset only phone
        if Constants.device == .phone {
            productivityTabBarItem.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
            productivityTabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10.adjust())
            
            localTabBarItem.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
            localTabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10.adjust())
            
            shareTabBarItem.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
            shareTabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10.adjust())
        }
        
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
