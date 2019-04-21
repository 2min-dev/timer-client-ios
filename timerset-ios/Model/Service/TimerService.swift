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
    
    func fetchTimerSet() -> Observable<TimerSet>
}

/// A service class that manage the application's timers
class TimerService: TimerServicePorotocol {
    // MARK: global state event
    var event: PublishSubject<TimerEvent> = PublishSubject()
    
    // MARK: properties
    
    init() {
        
    }
    
    func fetchTimerSet() -> Observable<TimerSet> {
        let timerSet = TimerSet(info: TimerSetInfo(name: "College entrance exam", description: "a timetable of colleage entrance exam"), timers: [
            JSTimer(info: TimerInfo(title: #"First Test - "Korean""#, endTime: 80 * 60 * 60)),
            JSTimer(info: TimerInfo(title: #"Break Time"#, endTime: 20 * 60)),
            JSTimer(info: TimerInfo(title: #"Second Test - "Math""#, endTime: 100 * 60 * 60)),
            JSTimer(info: TimerInfo(title: #"Lunch Time"#, endTime: 50 * 60)),
            JSTimer(info: TimerInfo(title: #"Third Test - "English""#, endTime: 70 * 60 * 60)),
            JSTimer(info: TimerInfo(title: #"Break Time"#, endTime: 20 * 60)),
            JSTimer(info: TimerInfo(title: #"Forth Test - "History""#, endTime: 30 * 60 * 60)),
            JSTimer(info: TimerInfo(title: #"Test Paper Change"#, endTime: 10 * 60)),
            JSTimer(info: TimerInfo(title: #"Forth Test - "Science #1""#, endTime: 30 * 60 * 60)),
            JSTimer(info: TimerInfo(title: #"Test Paper Change"#, endTime: 2 * 60)),
            JSTimer(info: TimerInfo(title: #"Forth Test - "Science #2""#, endTime: 30 * 60 * 60))
        ])
        
        return Observable.just(timerSet)
    }
}
