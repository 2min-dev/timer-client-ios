//
//  TimerSetInfo.swift
//  timerset-ios
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

class TimerSetInfo: Codable {
    /// A state of the timer set
    enum State: Int, Codable {
        case stop = 0
        case start
        case pause
        case end
    }
    
    // MARK: properties
    var name: String // Name of the timer set
    var description: String // Description of the timer set
    var state: State // Current state of the timer set
    
    // MARK: constructor
    init(name: String, description: String, state: State) {
        self.name = name
        self.description = description
        self.state = state
    }
    
    convenience init(name: String, description: String) {
        self.init(name: name, description: description, state: .stop)
    }
}
