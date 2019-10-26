//
//  RunningTimeSet.swift
//  timer
//
//  Created by JSilver on 2019/10/24.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

struct RunningTimeSet: Codable {
    let timeSet: TimeSet
    let origin: TimeSetInfo
    let startDate: Date
    
    enum CodingKeys: String, CodingKey {
        case info
        case origin
        case index
        case startDate
    }
    
    // MARK: - constructor
    init(timeSet: TimeSet, origin: TimeSetInfo, startDate: Date) {
        self.timeSet = timeSet
        self.origin = origin
        self.startDate = startDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let info = try container.decode(TimeSetInfo.self, forKey: .info)
        let index = try container.decode(Int.self, forKey: .index)
        
        timeSet = TimeSet(info: info, index: index)
        origin = try container.decode(TimeSetInfo.self, forKey: .origin)
        startDate = try container.decode(Date.self, forKey: .startDate)
    }
    
    // MARK: - codable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timeSet.info, forKey: .info)
        try container.encode(origin, forKey: .origin)
        try container.encode(timeSet.currentIndex, forKey: .index)
        try container.encode(startDate, forKey: .startDate)
    }
}
