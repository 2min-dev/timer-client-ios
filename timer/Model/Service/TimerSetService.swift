//
//  TimerService.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 16/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

enum TimerSetEvent {
    
}

protocol TimerSetServicePorotocol {
    var event: PublishSubject<TimerSetEvent> { get }
    
    func fetchTimerSets() -> Observable<[TimerSet]>
    func createTimerSet(info: TimerSetInfo) -> Observable<TimerSet>
    func deleteTimerSet(_ timerSet: TimerSet) -> Observable<TimerSet>
    func updateTimerSet(_ timerSet: TimerSet) -> Observable<TimerSet>
}

/// A service class that manage the application's timers
class TimerSetService: TimerSetServicePorotocol {
    // MARK: global state event
    var event: PublishSubject<TimerSetEvent> = PublishSubject()
    
    // MARK: - properties
    private var timerSets: [TimerSet]
    
    // MARK: - constructor
    init() {
        // Create timer set mock
        var timerSet = TimerSet(info: TimerSetInfo(name: "First Sample Timer set", description: "5 sec -> 3 sec -> 5 sec -> end"))
        timerSet.createTimer(info: TimerInfo(title: "First timer (5 sec)", endTime: 5))
        timerSet.createTimer(info: TimerInfo(title: "Second timer (3 sec)", endTime: 3))
        timerSet.createTimer(info: TimerInfo(title: "Third timer (5 sec)", endTime: 5))
        
        timerSets = [
            timerSet,
            TimerSet(info: TimerSetInfo(name: "Empty timer set 1", description: "")),
            TimerSet(info: TimerSetInfo(name: "Empty timer set 2", description: "")),
            TimerSet(info: TimerSetInfo(name: "Empty timer set 3", description: ""))
        ]
    }
    
    // MARK: - public method
    /// Fetch timer set list
    func fetchTimerSets() -> Observable<[TimerSet]> {
        return Observable.just(timerSets)
    }
    
    /// Create a timer set
    func createTimerSet(info: TimerSetInfo) -> Observable<TimerSet> {
        let timerSet = TimerSet(info: info)
        timerSets.append(timerSet)
        return Observable.just(timerSet)
    }
    
    /// Delete the timer set
    func deleteTimerSet(_ timerSet: TimerSet) -> Observable<TimerSet> {
        guard let index = timerSets.firstIndex(where: { $0 === timerSet }) else { return Observable.empty() }
        return Observable.just(timerSets.remove(at: index))
    }
    
    /// Update the timer set
    func updateTimerSet(_ timerSet: TimerSet) -> Observable<TimerSet> {
        guard let index = timerSets.firstIndex(where: { $0 === timerSet }) else { return Observable.empty() }
        timerSets[index].info = timerSet.info
        return Observable.just(timerSets[index])
    }
}
