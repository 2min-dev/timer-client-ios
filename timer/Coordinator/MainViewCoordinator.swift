//
//  MainViewCoordinator.swift
//  timerset-ios
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
        
        let timerSetViewController = TimerSetListViewController()
        let timerSetViewCoordinator = TimerSetListViewCoordinator(provider: provider, rootViewController: timerSetViewController)
        let timerSetViewReactor = TimerSetListViewReactor(timerService: provider.timerService)
        
        let settingViewController = SettingViewController()
        let settingViewCoordinator = SettingViewCoordinator(provider: provider, rootViewController: settingViewController)
        let settingViewReactor = SettingViewReactor(appService: provider.appService)
        
        // DI
        productivityViewController.coordinator = productivityViewCoordinator
        productivityViewController.reactor = productivityViewReactor
        
        timerSetViewController.coordinator = timerSetViewCoordinator
        timerSetViewController.reactor = timerSetViewReactor
        
        settingViewController.coordinator = settingViewCoordinator
        settingViewController.reactor = settingViewReactor
        
        let productivityTabBarItem = UITabBarItem(title: "tab_button_home".localized, image: nil, tag: 0)
        let rootProductivityViewController = RootViewController(rootViewController: productivityViewController)
        rootProductivityViewController.tabBarItem = productivityTabBarItem
        
        let timerSetTabBarItem = UITabBarItem(title: "tab_button_local_time_set".localized, image: nil, tag: 0)
        timerSetViewController.tabBarItem = timerSetTabBarItem
        
        let settingTabBarItem = UITabBarItem(title: "tab_button_shared_time_set".localized, image: nil, tag: 0)
        settingViewController.tabBarItem = settingTabBarItem
        
        self.rootViewController.viewControllers = [timerSetViewController, rootProductivityViewController, settingViewController]
    }
    
    func present(for route: MainRoute) {
        
    }
}
