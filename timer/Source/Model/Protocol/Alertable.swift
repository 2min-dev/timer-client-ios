//
//  Alertable.swift
//  timer
//
//  Created by JSilver on 2019/10/29.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

protocol Alertable {
    /// Alarm info to alert
    var alarm: Alarm { get }
    
    /// Alert alarm
    func alert()
}

extension Alertable {
    func alert() {
        alarm.alert()
    }
}
