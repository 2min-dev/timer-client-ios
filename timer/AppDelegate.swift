//
//  AppDelegate.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import UserNotifications
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // init SwiftBeaver
        Logger.initialize()
        
        // create new window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // present intro view
        let appCoordinator: AppCoordinator = AppCoordinator(provider: ServiceProvider(), window: window!)
        appCoordinator.present(for: .intro)
        return true
    }
    
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        let content = UNMutableNotificationContent()
//        content.title = "Timer done."
//        content.subtitle = "done done"
//        content.body = "don don don"
//        content.sound = UNNotificationSound(named: UNNotificationSoundName.init("default"))
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//        let request = UNNotificationRequest(identifier: "timer", content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { error in
//            if error == nil {
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//            }
//        }
//    }
}
