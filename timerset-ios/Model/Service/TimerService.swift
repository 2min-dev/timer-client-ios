//
//  TimerService.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 16/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

enum TimerEvent {
    
}

protocol TimerServicePorotocol {
    var event: PublishSubject<TimerEvent> { get }
}

class TimerService: TimerServicePorotocol {
    // MARK: global state event
    var event: PublishSubject<TimerEvent> = PublishSubject()
    
    // MARK: properties
    var timers: [TimerModel]
    
    init() {
        timers = [
            TimerModel(title: "a", endTime: 10),
            TimerModel(title: "b", endTime: 20),
            TimerModel(title: "c", endTime: 30),
        ]
        timers[0].startTimer()
        timers[1].startTimer()
        timers[2].startTimer()
    }
}
