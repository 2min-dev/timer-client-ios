//
//  MainViewCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from main view (tab bar)
class MainViewCoordinator: CoordinatorProtocl {
     // MARK: route enumeration
    enum MainRoute {
        
    }
    
    weak var rootViewController: MainViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: MainViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
        
        // tab bar controller initialize
        let oneTouchTimerViewController = OneTouchTimerViewController()
        let oneTouchTimerViewCoordinator = OneTouchTimerViewCoordinator(provider: provider, rootViewController: oneTouchTimerViewController)
        let oneTouchTimerReactor = OneTouchTimerViewReactor(timerService: provider.timerService)
        
        let timerSetViewController = TimerSetViewController()
        let timerSetViewCoordinator = TimerSetViewCoordinator(provider: provider, rootViewController: timerSetViewController)
        let timerSetViewReactor = TimerSetViewReactor(timerService: provider.timerService)
        
        let settingViewController = SettingViewController()
        let settingViewCoordinator = SettingViewCoordinator(provider: provider, rootViewController: settingViewController)
        let settingViewReactor = SettingViewReactor(appService: provider.appService)
        
        // DI
        oneTouchTimerViewController.coordinator = oneTouchTimerViewCoordinator
        oneTouchTimerViewController.reactor = oneTouchTimerReactor
        
        timerSetViewController.coordinator = timerSetViewCoordinator
        timerSetViewController.reactor = timerSetViewReactor
        
        settingViewController.coordinator = settingViewCoordinator
        settingViewController.reactor = settingViewReactor
        
        let oneTouchTimerTabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
        oneTouchTimerViewController.tabBarItem = oneTouchTimerTabBarItem
        
        let timerSetTabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        timerSetViewController.tabBarItem = timerSetTabBarItem
        
        let settingTabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
        settingViewController.tabBarItem = settingTabBarItem
        
        self.rootViewController.viewControllers = [oneTouchTimerViewController, timerSetViewController, settingViewController]
    }
    
    func present(for route: MainRoute) {
        
    }
}
