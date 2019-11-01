//
//  StopWatchItem.swift
//  timer
//
//  Created by JSilver on 2019/10/29.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RealmSwift

class StopwatchItem: Object, Codable, NSCopying, Recordable {
    @objc dynamic var current: TimeInterval = 0
    @objc dynamic var end: TimeInterval = 0
    var isEnded: Bool = false
    
    // MARK: - constructor
    convenience init(current: TimeInterval) {
        self.init()
        self.current = current
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        return StopwatchItem(current: current)
    }
    
    @discardableResult
    func consume(time: TimeInterval) -> TimeInterval {
        current += time
        return time
    }
    
    func reset() {
        current = 0
    }
}
