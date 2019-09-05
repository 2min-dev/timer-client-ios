//
//  TimeSetInfo.swift
//  timer
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class TimeSetInfo: Object, Codable, NSCopying {
    @objc enum EndState: Int, Codable {
        /// The time set not ended
        case none
        /// The time set finished normally
        case normal
        /// The time set canceled
        case cancel
        /// The time set oevrtime recorded
        case overtime
    }
    
    // MARK: - properties
    // Default information of the time set
    @objc dynamic var id: String?                       // Identifier of the time set
    @objc dynamic var title: String = ""                // Name of the timer set
    @objc dynamic var memo: String = ""                 // Description of the timer set
    @objc dynamic var isBookmark: Bool = false          // Is bookmark of the time set
    
    // History record properties of the time set
    @objc dynamic var startDate: Date?                  // Start date of time set
    @objc dynamic var endDate: Date?                    // End date of time set
    @objc dynamic var repeatCount: Int = 0              // Repeat count of time set
    @objc dynamic var runningTime: TimeInterval = 0     // All running time of time set
    @objc dynamic var endState: EndState = .none        // End state of time set
    
    // Operation option of the time set
    @objc dynamic var isRepeat: Bool = false            // Is repeat of the time set
    
    var timers: List<TimerInfo> = List()                // Timer info list of the timer set
    @objc dynamic var overtimer: TimerInfo?             // Timer info about overtime record of time set
    
    // MARK: - constructor
    convenience init(id: String?,
                     title: String,
                     memo: String,
                     isBookmark: Bool,
                     isRepeat: Bool,
                     startDate: Date?,
                     endDate: Date?,
                     repeatCount: Int,
                     runningTime: TimeInterval,
                     endState: EndState,
                     timers: List<TimerInfo>,
                     overtimer: TimerInfo?) {
        self.init()
        
        self.id = id
        self.title = title
        self.memo = memo
        self.isBookmark = isBookmark
        self.isRepeat = isRepeat
        self.startDate = startDate
        self.endDate = endDate
        self.repeatCount = repeatCount
        self.runningTime = runningTime
        self.endState = endState
        self.timers = timers
        self.overtimer = overtimer
        
        if self.timers.isEmpty {
            // Add a default timer if timers is empty
            self.timers.append(TimerInfo())
        }
    }
    
    required init() {
        self.timers.append(TimerInfo())
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        self.timers.append(TimerInfo(comment: "테ㅡ트", alarm: "호우", currentTime: 0, endTime: 19, extraTime: 90))
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        self.timers.append(TimerInfo(comment: "테솧ㅎㅎ트", alarm: "호우2", currentTime: 0, endTime: 19, extraTime: 90))
        super.init(value: value, schema: schema)
    }
    
    // MARK: - realm method
    override class func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        let timers: List<TimerInfo> = List()
        timers.append(objectsIn: Array(self.timers.compactMap { $0.copy() as? TimerInfo }))
        
        return TimeSetInfo(id: id,
                           title: title,
                           memo: memo,
                           isBookmark: isBookmark,
                           isRepeat: isRepeat,
                           startDate: startDate,
                           endDate: endDate,
                           repeatCount: repeatCount,
                           runningTime: runningTime,
                           endState: endState,
                           timers: timers,
                           overtimer: overtimer)
    }
}
