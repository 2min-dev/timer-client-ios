//
//  History.swift
//  timer
//
//  Created by JSilver on 2019/10/15.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RealmSwift

@objc class History: Object {
    @objc dynamic var info: TimeSetInfo = TimeSetInfo()
    @objc dynamic var startDate: Date = Date()
    @objc dynamic var endDate: Date = Date()

    convenience init(info: TimeSetInfo, startDate: Date, endDate: Date) {
        self.init()
        self.info = info
        self.startDate = startDate
        self.endDate = endDate
    }
}
