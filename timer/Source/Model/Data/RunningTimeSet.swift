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
    let canSave: Bool
    
    enum CodingKeys: String, CodingKey {
        case item
        case history
        case origin
        case index
        case canSave
    }
    
    // MARK: - constructor
    init(timeSet: TimeSet, origin: TimeSetItem, canSave: Bool) {
        self.timeSet = timeSet
        self.origin = origin
        self.canSave = canSave
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let item = try container.decode(TimeSetItem.self, forKey: .item)
        let history = try container.decode(History.self, forKey: .history)
        let index = try container.decode(Int.self, forKey: .index)
        
        origin = try container.decode(TimeSetItem.self, forKey: .origin)
        timeSet = TimeSet(item: item, history: history, index: index)
        canSave = try container.decode(Bool.self, forKey: .canSave)
    }
    
    // MARK: - codable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timeSet.item, forKey: .item)
        try container.encode(timeSet.history, forKey: .history)
        try container.encode(origin, forKey: .origin)
        try container.encode(timeSet.currentIndex, forKey: .index)
        try container.encode(canSave, forKey: .canSave)
    }
}
