//
//  AppVersion.swift
//  timer
//
//  Created by JSilver on 2019/10/16.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

struct AppVersion: Codable {
    let version: String
    
    enum CodingKeys: String, CodingKey {
        case version = "ios_version"
    }
}
