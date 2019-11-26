//
//  Alertable.swift
//  timer
//
//  Created by JSilver on 2019/10/29.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import AVFoundation

protocol Alertable {
    /// Alarm info to alert
    var alarm: Alarm { get }
}
