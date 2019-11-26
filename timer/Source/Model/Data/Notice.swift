//
//  Notice.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

struct Notice: Codable {
    let id: Int
    let title: String
    let date: Date
}

struct NoticeDetail: Codable {
    let content: String
}
