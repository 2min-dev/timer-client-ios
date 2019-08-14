//
//  TimeSetInfo.swift
//  timer
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

class TimeSetInfo: Codable, NSCopying {
    enum State: Int, Codable {
        case none = 0
        case finished
        case canceled
        case exceeded
    }
    
    // MARK: - properties
    // Default information of the time set
    var id: String?             // Identifier of the time set
    var title: String           // Name of the timer set
    var memo: String            // Description of the timer set
    var isBookmark: Bool        // Is bookmark of the time set
    
    // Operation option of the time set
    var isRepeat: Bool          // Is repeat of the time set
    
    // History record properties of the time set
    var startDate: Date?        // Start date of time set
    var endDate: Date?          // End date of time set
    var repeatCount: Int        // Repeat count of time set
    var state: State            // Current state of the time set
    
    // Timers that makes up the time set
    var timers: [TimerInfo]     // Timer info list of the timer set
    var overtimer: TimerInfo?   // Timer for record overtime of time set
    
    // MARK: - constructor
    init(id: String? = nil,
         title: String = "",
         memo: String = "",
         isBookmark: Bool = false,
         isRepeat: Bool = false,
         startDate: Date? = nil,
         endDate: Date? = nil,
         repeatCount: Int = 0,
         state: State = .none,
         timers: [TimerInfo] = [],
         overtimer: TimerInfo? = nil) {
        self.id = id
        self.title = title
        self.memo = memo
        self.isBookmark = isBookmark
        self.isRepeat = isRepeat
        self.startDate = startDate
        self.endDate = endDate
        self.repeatCount = repeatCount
        self.state = state
        self.timers = timers
        self.overtimer = overtimer
        
        if self.timers.isEmpty {
            // Add a default timer if timers is empty
            let info = TimerInfo(title: String(format: "timer_default_title".localized, 1))
            self.timers.append(info)
        }
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        return TimeSetInfo(id: id,
                           title: title,
                           memo: memo,
                           isBookmark: isBookmark,
                           isRepeat: isRepeat,
                           startDate: startDate,
                           endDate: endDate,
                           repeatCount: repeatCount,
                           state: state,
                           timers: timers.compactMap { $0.copy() as? TimerInfo },
                           overtimer: overtimer?.copy() as? TimerInfo)
    }
}
