//
//  HistoryListCollectionViewCellReactor.swift
//  timer
//
//  Created by JSilver on 2019/10/13.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class HistoryListCollectionViewCellReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        /// All time of the time set
        var time: TimeInterval
        
        /// The title of the time set
        var title: String
        
        /// Started date of the time set
        var startedDate: Date
    }
    
    // MARK: - properties
    var initialState: State
    
    // MARK: - constructor
    init() {
        initialState = State(time: 0,
                             title: "샘플 타임셋",
                             startedDate: Date())
    }
    
    deinit {
        Logger.verbose()
    }
}
