//
//  ProductivityViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit
import RxDataSources

typealias ProductivityTimerSection = SectionModel<Void, ProductivityTimerCollectionViewCellReactor>

class ProductivityViewReactor: Reactor {
    enum Action {
        case updateTimeInput(Int)
        case tapTimeKey(ProductivityView.TimeKey)
        case clearTimer
        case addTimer
        case timerSelected(IndexPath)
    }
    
    enum Mutation {
        case setTime(Int)
        case setTimer(TimeInterval)
        case setSumOfTimers(TimeInterval)
        
        case appendSectionItem(ProductivityTimerSection.Item)
        case setSelectedIndexPath(IndexPath)
    }
    
    struct State {
        var time: Int
        var timer: TimeInterval
        var sumOfTimers: TimeInterval
        
        var sections: [ProductivityTimerSection]
        var selectedIndexPath: IndexPath
        
        var canStart: Bool
        var shouldReloadSection: Bool
    }
    
    // MARK: properties
    var initialState: State
    private let timerService: TimerSetServicePorotocol
    
    let timeSetInfo: TimeSetInfo // Default timer set info
    
    private var disposeBag = DisposeBag()
    
    init(timerService: TimerSetServicePorotocol) {
        // Create default a timer
        let info = TimerInfo(title: "1 번째 타이머", endTime: 0)
        
        // Create default timer set and add default a timer
        self.timeSetInfo = TimeSetInfo(name: "", description: "")
        self.timeSetInfo.timers.append(info)
 
        self.initialState = State(time: 0,
                                  timer: 0,
                                  sumOfTimers: 0,
                                  sections: [ProductivityTimerSection(model: Void(), items: [ProductivityTimerCollectionViewCellReactor(info: info, index: 1, selected: true)])],
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  canStart: false,
                                  shouldReloadSection: true)
        self.timerService = timerService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateTimeInput(time):
            return .just(Mutation.setTime(time))
        case let .tapTimeKey(key):
            var timeInterval = currentState.timer
            let sumOfTimers = currentState.sumOfTimers - timeInterval
            
            switch key {
            case .hour:
                timeInterval += Double(currentState.time * Constants.Time.hour)
            case .minute:
                timeInterval += Double(currentState.time * Constants.Time.minute)
            case .second:
                timeInterval += Double(currentState.time)
            }
            
            let setTimer = Observable.just(Mutation.setTimer(timeInterval))
            let setSumOfTimers = Observable.just(Mutation.setSumOfTimers(sumOfTimers + timeInterval))
            let setTime = Observable.just(Mutation.setTime(0))
            
            return .concat(setTimer, setSumOfTimers, setTime)
        case .clearTimer:
            let setTimer = Observable.just(Mutation.setTimer(0))
            let setTime = Observable.just(Mutation.setTime(0))
            let setSumOfTimers = Observable.just(Mutation.setSumOfTimers(currentState.sumOfTimers - currentState.timer))
            
            return .concat(setTimer, setTime, setSumOfTimers)
        case .addTimer:
            // Create default a timer (set 0)
            let info = TimerInfo(title: "\(timeSetInfo.timers.count + 1) 번째 타이머")
            // Add timer
            timeSetInfo.timers.append(info)
            
            let appendSectionItem = Observable.just(Mutation.appendSectionItem(ProductivityTimerCollectionViewCellReactor(info: info, index: timeSetInfo.timers.count)))
            let setSelectIndexPath = mutate(action: .timerSelected(IndexPath(row: timeSetInfo.timers.count - 1, section: 0)))
            
            return .concat(appendSectionItem, setSelectIndexPath)
        case let .timerSelected(indexPath):
            let setSelectedIndexPath = Observable.just(Mutation.setSelectedIndexPath(indexPath))
            let setTimer = Observable.just(Mutation.setTimer(timeSetInfo.timers[indexPath.row].endTime))
            let setTime = Observable.just(Mutation.setTime(0))
            
            return .concat(setSelectedIndexPath, setTimer, setTime)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldReloadSection = false
        
        switch mutation {
        case let .setTime(time):
            state.time = time
            return state
        case let .setTimer(timeInterval):
            // Update time
            let timerReactor = state.sections[0].items[state.selectedIndexPath.row]
            timerReactor.action.onNext(.updateTime(timeInterval))
            
            state.timer = timeInterval
            state.canStart = state.sections[0].items.count > 1 || state.timer > 0
            return state
        case let .setSumOfTimers(timeInterval):
            state.sumOfTimers = timeInterval
            return state
        case let .appendSectionItem(reactor):
            state.sections[0].items.append(reactor)
            
            state.canStart = true
            state.shouldReloadSection = true
            return state
        case let .setSelectedIndexPath(indexPath):
            // Deselect previous selected timer
            let previousItem = state.sections[0].items[state.selectedIndexPath.row]
            previousItem.action.onNext(.select(false))
            
            // Select current selected timer
            let item = state.sections[0].items[indexPath.row]
            item.action.onNext(.select(true))
            
            state.selectedIndexPath = indexPath
            return state
        }
    }
}
