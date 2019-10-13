//
//  TimeSetCollectionViewCellReactor.swift
//  timer
//
//  Created by JSilver on 09/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetCollectionViewCellReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        /// Title of the time set
        var title: String
        
        /// All time of the time set
        var allTime: TimeInterval
        
        /// All timer count of the time set
        var timerCount: Int
    }
    
    // MARK: - properties
    var initialState: State
    var timeSetInfo: TimeSetInfo
    
    // MARK: - constructor
    init(timeSetInfo: TimeSetInfo) {
        self.timeSetInfo = timeSetInfo
        self.initialState = State(title: timeSetInfo.title,
                                  allTime: timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                                  timerCount: timeSetInfo.timers.count)
    }
}
