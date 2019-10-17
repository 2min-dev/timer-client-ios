//
//  History.swift
//  timer
//
//  Created by JSilver on 2019/10/15.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RealmSwift

@objc class History: Object, NSCopying {
    // MARK: - properties
    @objc dynamic private(set) var id: Int = -1
    @objc dynamic var info: TimeSetInfo?
    @objc dynamic private var _startDate: Date?
    var startDate: Date? {
        set {
            guard let date = newValue, _startDate == nil else { return }
            _startDate = date
            
            // Set history id from seconds of start date
            id = Int(date.timeIntervalSince1970)
        }
        get {
            return _startDate
        }
    }
    @objc dynamic var endDate: Date?
    
    // MARK: - constructor
    convenience init(info: TimeSetInfo) {
        self.init()
        self.info = info
    }
    
    // MARK: - realm method
    override class func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        let history = History()
        history.info = info?.copy() as? TimeSetInfo
        history.startDate = startDate
        history.endDate = endDate
        
        return history
    }
}
