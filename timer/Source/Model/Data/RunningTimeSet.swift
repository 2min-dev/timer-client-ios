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
    let origin: TimeSetItem
    let startDate: Date
    
    enum CodingKeys: String, CodingKey {
        case item
        case origin
        case index
        case startDate
    }
    
    // MARK: - constructor
    init(timeSet: TimeSet, origin: TimeSetItem, startDate: Date) {
        self.timeSet = timeSet
        self.origin = origin
        self.startDate = startDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let item = try container.decode(TimeSetItem.self, forKey: .item)
        let index = try container.decode(Int.self, forKey: .index)
        
        timeSet = TimeSet(item: item, index: index)
        origin = try container.decode(TimeSetItem.self, forKey: .origin)
        startDate = try container.decode(Date.self, forKey: .startDate)
    }
    
    // MARK: - codable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timeSet.item, forKey: .item)
        try container.encode(origin, forKey: .origin)
        try container.encode(timeSet.currentIndex, forKey: .index)
        try container.encode(startDate, forKey: .startDate)
    }
}
