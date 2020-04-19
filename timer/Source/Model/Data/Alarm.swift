//
//  Alarm.swift
//  timer
//
//  Created by JSilver on 07/10/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RealmSwift
import AVFoundation

@objc enum Alarm: Int, RealmEnum, CaseIterable, Codable {
    case `default` = 0
    case vibrate
    case silence
    
    enum SoundType {
        case short
        case medium
        case long
        
        var postfix: String {
            switch self {
            case .short:
                return "1x"
                
            case .medium:
                return "3x"
                
            case .long:
                return "10x"
            }
        }
    }
    
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
            return "alarm_default"
            
        case .silence, .vibrate:
            return nil
        }
    }
    
    var ext: String? {
        switch self {
        case .default:
            return "mp3"
            
        case .silence, .vibrate:
            return nil
        }
    }
    
    // MARK: - public method
    func getFileName(type: SoundType, withExt: Bool = false) -> String? {
        guard let fileName = fileName, let ext = ext else { return nil }
        return "\(fileName)_\(type.postfix)" + (withExt ? ".\(ext)" : "")
    }
}
