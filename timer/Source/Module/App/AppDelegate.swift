//
//  AppDelegate.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import UserNotifications
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
        provider.appService.setBackgroundDate(Date())
        
        // Store current running time set data into user defaults
        guard let timeSet = provider.timeSetService.storeTimeSet() else { return }
        timeSet.pause()
        
        // Register time set notification
        provider.notificationService.registerNotificationOfTimeSet(timeSet)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Restore bakckground entry date and compare with current date
        guard let backgroundDate = provider.appService.getBackgroundDate() else { return }
        let passedTime = Date().timeIntervalSince1970 - backgroundDate.timeIntervalSince1970
        
        guard let timeSet = provider.timeSetService.runningTimeSet?.timeSet,
            provider.appService.getRunningTimeSet() != nil else { return }
        
        // Consume the passed time and restart the time set
        timeSet.consume(time: passedTime)
        timeSet.start()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Remove all notifications when app state became active
        provider.notificationService.removeAllNotifications()
    }
    
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
