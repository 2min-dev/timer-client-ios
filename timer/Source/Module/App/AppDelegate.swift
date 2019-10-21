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
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let provider: ServiceProviderProtocol = ServiceProvider()

    // MARK: - lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize `SwiftBeaver`
        Logger.initialize()
        // Initialize `Realm`
        migrateRealm()
        
        // Create new window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Present intro view
        let appCoordinator: AppCoordinator = AppCoordinator(provider: provider, window: window!)
        appCoordinator.present(for: .intro)
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save current date when application did enter background state
        let date = Date()
        provider.appService.setBackgroundDate(date)
        
        Logger.info("Application did enter background - \(date)", tag: "APP")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Restore date of enter background and compare current date
        guard let backgroundDate = provider.appService.getBackgroundDate() else { return }
        let date = Date()
        let passedTime = date.timeIntervalSince1970 - backgroundDate.timeIntervalSince1970
        
        Logger.debug("Application did enter foreground - \(date), passed: \(passedTime.rounded())s")
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
    
    // MARK: - private method
    private func migrateRealm() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            schemaVersion: 0,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // Nothing yet
            })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
}
