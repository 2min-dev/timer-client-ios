//
//  TimeSetItem.swift
//  timer
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class TimeSetItem: Object, NSCopying, Codable {
    // MARK: - properties
    // Default information of the time set
    @objc dynamic var id: String?                       // Identifier of the time set
    @objc dynamic var title: String = ""                // Name of the timer set
    @objc dynamic var isRepeat: Bool = false            // Is repeat of the time set
    @objc dynamic var isBookmark: Bool = false          // Is bookmark of the time set
    
    var timers: List<TimerItem> = List()                // Timer item list of the timer set
    @objc dynamic var overtimer: StopwatchItem?         // Timer item about overtime record of time set
    
    // Sorting key
    @objc dynamic var sortingKey: Int = Int.max         // Sorting key of time set
    @objc dynamic var bookmarkSortingKey: Int = Int.max // Sorting key of bookmarked time set
    
    // MARK: - constructor
    convenience init(id: String?,
                     title: String,
                     isBookmark: Bool,
                     isRepeat: Bool,
                     timers: List<TimerItem>,
                     overtimer: StopwatchItem?,
                     sortingKey: Int,
                     bookmarkSortingKey: Int) {
        self.init()
        self.id = id
        self.title = title
        self.isBookmark = isBookmark
        self.isRepeat = isRepeat
        self.timers = timers
        self.overtimer = overtimer
        self.sortingKey = sortingKey
        self.bookmarkSortingKey = bookmarkSortingKey
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isRepeat = try container.decode(Bool.self, forKey: .isRepeat)
        timers = try container.decode([TimerItem].self, forKey: .timers).toList()
    }
    
    // MARK: - realm method
    override class func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        let timers: List<TimerItem> = List()
        timers.append(objectsIn: self.timers.compactMap { $0.copy() as? TimerItem })
        
        return TimeSetItem(id: id,
                           title: title,
                           isBookmark: isBookmark,
                           isRepeat: isRepeat,
                           timers: timers,
                           overtimer: overtimer?.copy() as? StopwatchItem,
                           sortingKey: sortingKey,
                           bookmarkSortingKey: bookmarkSortingKey)
    }
    
    func reset() {
        timers.forEach { $0.reset() }
    }
}
