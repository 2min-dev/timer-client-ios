//
//  NotificationService.swift
//  timer
//
//  Created by JSilver on 2019/10/25.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import NotificationCenter

protocol NotificationServiceProtocol {
    /// Register notifications of time set
    func registerNotificationOfTimeSet(_ timeSet: TimeSet)
    
    /// Remove all registered notifications
    func removeAllNotifications()
}

class NotificationService: BaseService, NotificationServiceProtocol {
    
    func registerNotificationOfTimeSet(_ timeSet: TimeSet) {
        let timers = timeSet.item.timers
        let lastIndex = timers.count - 1
        
        var baseTime: TimeInterval = 0
        timers.enumerated()
            .filter { offset, _ in offset >= timeSet.currentIndex }
            .forEach { offset, timer in
                let content = UNMutableNotificationContent()
                content.title = timeSet.item.title
                
                if offset == lastIndex {
                    // Set content of time set end
                    content.subtitle = "notification_time_set_end_sub_title".localized
                    content.body = timeSet.item.isRepeat ? "notification_time_set_end_repeat_body_title".localized : "notification_time_set_end_body_title".localized
                    
                    if let fileName = timer.alarm.getFileName(type: .medium, withExt: true) {
                        // Set push notification sound that time set ended
                        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: fileName))
                    }
                } else {
                    // Set content of timer end
                    content.subtitle = String(format: "notification_timer_end_sub_title_format".localized, offset + 1)
                    
                    if let fileName = timer.alarm.getFileName(type: .short, withExt: true) {
                        // Set push notification sound that timer ended
                        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: fileName))
                    }
                }
                
                // Create notification trigger and request
                let delay = timer.end + timer.extra - timer.current
                guard baseTime + delay > 0 else { return }
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: baseTime + delay, repeats: false)
                let request = UNNotificationRequest(identifier: String(offset), content: content, trigger: trigger)
                
                // Register notification
                UNUserNotificationCenter.current().add(request)
                baseTime += delay
        }
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
