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
    @objc dynamic private(set) var id: Int = -1             // Identifier
    @objc dynamic var item: TimeSetItem?                    // Performed time set info of history (Non-Optional)
    @objc dynamic var originId: Int = -1                    // Origin time set item id
    
    @objc dynamic var startDate: Date? {
        didSet { id = Int(startDate?.timeIntervalSince1970 ?? -1) }
    }
    @objc dynamic var endDate: Date?
    
    @objc dynamic var memo: String = ""                     // Memo of ran time set
    @objc dynamic var repeatCount: Int = 0                  // Repeated count of ran time set
    @objc dynamic var runningTime: TimeInterval = 0         // Total running time of ran time set
    @objc dynamic var extraTime: TimeInterval = 0           // Added all extra time of rna time set
    
    @objc dynamic var endState: EndState = .none            // End state of ran time set
    @objc dynamic var endIndex: Int = 0                     // End index of ran time set
    
    // MARK: - constructor
    convenience init(item: TimeSetItem) {
        self.init()
        self.item = item
        self.originId = item.id
    }
    
    private convenience init(
        id: Int,
        item: TimeSetItem?,
        originId: Int,
        startDate: Date?,
        endDate: Date?,
        memo: String,
        repeatCount: Int,
        runningTime: TimeInterval,
        extraTime: TimeInterval,
        endState: EndState,
        endIndex: Int
    ) {
        self.init()
        self.id = id
        self.item = item
        self.originId = originId
        self.startDate = startDate
        self.endDate = endDate
        self.memo = memo
        self.repeatCount = repeatCount
        self.runningTime = runningTime
        self.extraTime = extraTime
        self.endState = endState
        self.endIndex = endIndex
    }
    
    // MARK: - realm method
    override class func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        History(
            id: id,
            item: item?.copy() as? TimeSetItem,
            originId: originId,
            startDate: startDate,
            endDate: endDate,
            memo: memo,
            repeatCount: repeatCount,
            runningTime: runningTime,
            extraTime: extraTime,
            endState: endState,
            endIndex: endIndex
        )
    }
}
