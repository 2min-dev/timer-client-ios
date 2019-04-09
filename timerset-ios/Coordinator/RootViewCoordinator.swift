//
//  RootCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class RootViewCoordinator: NSObject {
    let rootViewController: RootViewController
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.rootViewController = RootViewController()
        self.provider = provider
        super.init()
        
        // DI
        self.rootViewController.coordinator = self
        
        // tab bar controller initialize
        let oneTouchTimerViewCoordinator = OneTouchTimerViewCoordinator(provider: provider)
        let timerSetViewCoordinator = TimerSetViewCoordinator(provider: provider)
        let settingCoordinator = SettingViewCoordinator(provider: provider)
        
        let oneTouchTimerViewController = oneTouchTimerViewCoordinator.rootViewController
        let timerSetViewController = timerSetViewCoordinator.rootViewController
        let settingViewController = settingCoordinator.rootViewController
        
        let oneTouchTimerTabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
        oneTouchTimerViewController.tabBarItem = oneTouchTimerTabBarItem
        
        let timerSetTabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        timerSetViewController.tabBarItem = timerSetTabBarItem
        
        let settingTabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
        settingViewController.tabBarItem = settingTabBarItem
        
        self.rootViewController.viewControllers = [oneTouchTimerViewController, timerSetViewController, settingViewController]
    }
}
