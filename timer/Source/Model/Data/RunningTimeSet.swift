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
    
    enum CodingKeys: String, CodingKey {
        case item
        case origin
        case index
        case startDate
    }
    
    // MARK: - constructor
    init(timeSet: TimeSet, origin: TimeSetItem) {
        self.timeSet = timeSet
        self.origin = origin
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let item = try container.decode(TimeSetItem.self, forKey: .item)
        let index = try container.decode(Int.self, forKey: .index)
        let startDate = try container.decode(Date.self, forKey: .startDate)
        
        timeSet = TimeSet(item: item, index: index)
        timeSet.history.startDate = startDate
        
        origin = try container.decode(TimeSetItem.self, forKey: .origin)
        
    }
    
    // MARK: - codable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timeSet.item, forKey: .item)
        try container.encode(origin, forKey: .origin)
        try container.encode(timeSet.currentIndex, forKey: .index)
        try container.encode(timeSet.history.startDate, forKey: .startDate)
    }
}
