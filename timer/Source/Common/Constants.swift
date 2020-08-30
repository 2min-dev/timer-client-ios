//
//  CommonConstants.swift
//  timer
//
//  Created by Jeong Jin Eun on 24/12/2018.
//  Copyright © 2018 Jeong Jin Eun. All rights reserved.
//

import Foundation
import UIKit

enum Constants {
    static var appTitle: String? { return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String }
    static var appVersion: String? { return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }
    static var appBuild: String? { return Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String }
    static var deviceVersion: String { return UIDevice.current.systemVersion }
    
    // base screen display weight
    static let weight: CGFloat = {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return UIScreen.main.bounds.width / 375.0
        case .pad:
            return UIScreen.main.bounds.width / 768.0
        default:
            // default isn't have mean yet.
            return UIScreen.main.bounds.width / 32.0
        }
    }()
    
    // second time
    enum Time {
        static let hour: TimeInterval = 3600
        static let minute: TimeInterval = 60
    }
    
    enum Locale {
        static let Korea: String = "ko_KR"
        static let USA: String = "en_US"
    }
}
