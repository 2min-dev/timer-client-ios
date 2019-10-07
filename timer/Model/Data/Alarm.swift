//
//  Alarm.swift
//  timer
//
//  Created by JSilver on 07/10/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

@objc enum Alarm: Int, CaseIterable, Codable {
    case `default` = 0
    case vibrate
    case silence
    
    var title: String {
        switch self {
        case .default:
            return "alarm_default_title".localized
            
        case .vibrate:
            return "alarm_vibrate_title".localized
            
        case .silence:
            return "alarm_silence_title".localized
        }
    }
    
    var fileName: String? {
        switch self {
        case .default:
            return "alarm_default.mp3" // TODO: not real file
            
        case .silence, .vibrate:
            return nil
        }
    }
}
