//
//  History.swift
//  timer
//
//  Created by JSilver on 2019/10/15.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RealmSwift

@objc class History: Object, NSCopying, Codable {
    @objc enum EndState: Int, Codable {
        /// The time set not ended
        case none = 0
        /// The time set finished normally
        case normal
        /// The time set canceled
        case cancel
        /// The time set oevrtime recorded
        case overtime
    }
    
    // MARK: - properties
    @objc dynamic private(set) var id: Int = -1
    @objc dynamic var item: TimeSetItem?
    
    @objc dynamic var memo: String = ""
    @objc dynamic var repeatCount: Int = 0
    @objc dynamic var runningTime: TimeInterval = 0
    @objc dynamic var extraTime: TimeInterval = 0
    @objc dynamic var endState: EndState = .none
    @objc dynamic var isSaved: Bool = false
    
    @objc dynamic var startDate: Date? {
        didSet { id = Int(startDate?.timeIntervalSince1970 ?? -1) }
    }
    @objc dynamic var endDate: Date?
    
    // MARK: - constructor
    convenience init(item: TimeSetItem?,
                     memo: String = "",
                     repeatCount: Int = 0,
                     runningTime: TimeInterval = 0,
                     extraTime: TimeInterval = 0,
                     endState: EndState = .none,
                     isSaved: Bool = false,
                     startDate: Date? = nil,
                     endDate: Date? = nil) {
        self.init()
        self.id = Int(startDate?.timeIntervalSince1970 ?? -1)
        self.item = item
        self.memo = memo
        self.repeatCount = repeatCount
        self.runningTime = runningTime
        self.extraTime = extraTime
        self.isSaved = isSaved
        self.endState = endState
        self.startDate = startDate
        self.endDate = endDate
    }
    
    // MARK: - realm method
    override class func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        return History(item: item?.copy() as? TimeSetItem,
                       memo: memo,
                       repeatCount: repeatCount,
                       runningTime: runningTime,
                       extraTime: extraTime,
                       endState: endState,
                       isSaved: isSaved,
                       startDate: startDate,
                       endDate: endDate)
    }
}
