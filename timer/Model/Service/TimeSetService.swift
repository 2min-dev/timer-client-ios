//
//  TimerService.swift
//  timer
//
//  Created by Jeong Jin Eun on 16/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

enum TimeSetEvent {
    
}

protocol TimeSetServicePorotocol {
    var event: PublishSubject<TimeSetEvent> { get }
    
    func fetchTimeSets() -> Observable<[TimeSet]>
    func createTimeSet(info: TimeSetInfo) -> Observable<TimeSet>
    func deleteTimeSet(_ timeSet: TimeSet) -> Observable<TimeSet>
}

/// A service class that manage the application's timers
class TimeSetService: TimeSetServicePorotocol {
    // MARK: global state event
    var event: PublishSubject<TimeSetEvent> = PublishSubject()
    
    // MARK: - properties
    private var timeSets: [TimeSet]
    
    // MARK: - constructor
    init() {
        // Create timer set mock
        let timeSet = TimeSet(info: TimeSetInfo(name: "First Sample Timer set", description: "5 sec -> 3 sec -> 5 sec -> end"))
        timeSet.createTimer(info: TimerInfo(title: "First timer (5 sec)", endTime: 5))
        timeSet.createTimer(info: TimerInfo(title: "Second timer (3 sec)", endTime: 3))
        timeSet.createTimer(info: TimerInfo(title: "Third timer (5 sec)", endTime: 5))
    
        let timeSet2 = TimeSet(info: TimeSetInfo(name: "Second Sample Timer set", description: "3 sec -> 5 sec -> end"))
        timeSet2.createTimer(info: TimerInfo(title: "First timer (3 sec)", endTime: 3))
        timeSet2.createTimer(info: TimerInfo(title: "Second timer (5 sec)", endTime: 5))
        
        timeSets = [
            timeSet,
            timeSet2,
            TimeSet(info: TimeSetInfo(name: "Empty timer set 1", description: "")),
            TimeSet(info: TimeSetInfo(name: "Empty timer set 2", description: ""))
        ]
    }
    
    // MARK: - public method
    /// Fetch timer set list
    func fetchTimeSets() -> Observable<[TimeSet]> {
        return Observable.just(timeSets)
    }
    
    /// Create a timer set
    func createTimeSet(info: TimeSetInfo) -> Observable<TimeSet> {
        let timeSet = TimeSet(info: info)
        timeSets.append(timeSet)
        return Observable.just(timeSet)
    }
    
    /// Delete the timer set
    func deleteTimeSet(_ timeSet: TimeSet) -> Observable<TimeSet> {
        guard let index = timeSets.firstIndex(where: { $0 === timeSet }) else { return Observable.empty() }
        let timeSet = timeSets.remove(at: index)
        return Observable.just(timeSet)
    }
}
