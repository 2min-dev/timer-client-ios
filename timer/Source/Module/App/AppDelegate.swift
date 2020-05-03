//
//  AppDelegate.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation
import RealmSwift
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private let provider: ServiceProviderProtocol = ServiceProvider()
    private lazy var appService: AppServiceProtocol = provider.appService
    private lazy var timeSetService: TimeSetServiceProtocol = provider.timeSetService
    private lazy var notificationService: NotificationServiceProtocol = provider.notificationService

    // MARK: - lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase Analytics (only release)
        #if !DEBUG
        FirebaseApp.configure()
        #endif
        // Initialize `Realm`
        migrateRealm()
        // Set audio session category to play at the same time with other app's audio
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        
        // Create new window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Present intro view
        let appCoordinator: AppCoordinator = AppCoordinator(window: window!, provider: provider)
        appCoordinator.present(for: .intro, animated: true)
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save current date when application did enter background state
        appService.setBackgroundDate(Date())
        
        // Store current running time set data into user defaults
        guard let timeSet = timeSetService.runningTimeSet?.timeSet,
            timeSet.state == .run else { return }
        timeSetService.storeTimeSet()
        timeSet.pause()
        
        // Register time set notification
        notificationService.registerNotificationOfTimeSet(timeSet)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Restore bakckground entry date and compare with current date
        guard let backgroundDate = appService.getBackgroundDate() else { return }
        let passedTime = Date().timeIntervalSince1970 - backgroundDate.timeIntervalSince1970
        
        guard let timeSet = timeSetService.restoreTimeSet() else { return }
        
        // Consume the passed time and restart the time set
        timeSet.consume(time: passedTime)
        timeSet.start()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Remove all notifications when app state became active
        notificationService.removeAllNotifications()
    }
    
    // MARK: - private method
    private func migrateRealm() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            schemaVersion: 2,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // Migrate history model
                    migration.enumerateObjects(ofType: History.className()) { oldObject, newObject in
                        guard let oldObject = oldObject, let newObject = newObject else { return }
                        
                        // Migrate to set end index by timer's current time
                        let timeSetItem = oldObject["item"]! as! MigrationObject
                        let timers = timeSetItem["timers"] as! List<MigrationObject>
                        newObject["endIndex"] = timers.firstIndex {
                            let current = $0["current"] as! TimeInterval
                            let target = $0["target"] as! TimeInterval
                            let extra = $0["extra"] as! TimeInterval
                            return current > 0 && current < target + extra
                        } ?? timers.count - 1
                    }
                }
                
                if oldSchemaVersion < 2 {
                    // Migrate time set item model
                    var id = 1
                    migration.enumerateObjects(ofType: TimeSetItem.className()) { oldObject, newObject in
                        guard let oldObject = oldObject, let newObject = newObject else { return }
                        
                        if let id = oldObject["id"] as? String, !id.contains("H") {
                            // Set historical time set object
                            newObject["isSaved"] = true
                        }
                        
                        // Realloc id of time set item (String -> Int)
                        newObject["id"] = id
                        id += 1
                    }
                    // Set last time set id to user default
                    self.appService.setTimeSetId(id)
                }
            })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
}
