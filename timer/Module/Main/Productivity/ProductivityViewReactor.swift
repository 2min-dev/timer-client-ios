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

class ProductivityViewReactor: Reactor {
    // MARK: - constants
    private static let MAX_TIME_INTERVAL = TimeInterval(99 * Constants.Time.hour + 59 * Constants.Time.minute + 59)
    
    enum Time: Int {
        case hour = 0
        case minute
        case second
    }
    
    enum TimeSetAction {
        case Move
        case Select
        case None
    }
    
    enum Action {
        case clear
        
        case tapKeyPad(Int)
        case tapTime(Time)
        case toggleTimeSetLoop
        
        case addTimer
        case deleteTimer
        case moveTimer(at: IndexPath, to: IndexPath)
        case selectTimer(at: IndexPath)
        
        case applyAlarm(String)
    }
    
    enum Mutation {
        case setTime(Int)
        case setTimer(TimeInterval)
        case setSumOfTimers(TimeInterval)
        case setTimeSetLoop(Bool)
        
        case appendTimer(TimerInfo)
        case removeTimer(at: Int)
        case swapTimer(at: IndexPath, to: IndexPath)
        
        case setSelectedIndexPath(IndexPath)
        case setTimeSetAction(TimeSetAction)
        
        case setSelectableTime(Time)
        case setTimerOptionVisible(Bool)
        
        case alert(String)
        case sectionReload
    }
    
    struct State {
        var time: Int                       // The time that user inputed
        var timer: TimeInterval             // The time of timer
        var sumOfTimers: TimeInterval       // The time that sum of all timers
        var isTimeSetLoop: Bool             // Is the time set loop
        
        var timers: [TimerInfo]             // The timer list model of timer set
        
        var selectedIndexPath: IndexPath    // Current selected timer index path
        var timeSetAction: TimeSetAction    // To distinguish timer set operation
        
        var selectableTime: Time            // Selectable time key based on current time
        var canTimeSetStart: Bool           // Can the time set start
        var isTimerOptionVisible: Bool      // Is the timer option view visible
        
        var alert: String?                  // Alert message
        var shouldSectionReload: Bool       // Need section reload
    }
    
    // MARK: properties
    var initialState: State
    private let timerService: TimeSetServicePorotocol
    
    let timeSetInfo: TimeSetInfo // Empty timer set info
    
    init(timerService: TimeSetServicePorotocol) {
        self.timerService = timerService
        
        // Create default a timer
        let info = TimerInfo(title: "1 번째 타이머")
        
        // Create default timer set and add default a timer
        self.timeSetInfo = TimeSetInfo(name: "", description: "")
        self.timeSetInfo.timers.append(info)
 
        self.initialState = State(time: 0,
                                  timer: 0,
                                  sumOfTimers: 0,
                                  isTimeSetLoop: false,
                                  timers: timeSetInfo.timers,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  timeSetAction: .Select,
                                  selectableTime: .hour,
                                  canTimeSetStart: false,
                                  isTimerOptionVisible: false,
                                  alert: nil,
                                  shouldSectionReload: true)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .tapKeyPad(time):
            let setTime: Observable<Mutation> = .just(Mutation.setTime(time))
            var setSelectableTimeKey: Observable<Mutation>
            if currentState.timer + TimeInterval(time) > ProductivityViewReactor.MAX_TIME_INTERVAL {
                // Call mutate recursivly through max time value
                return mutate(action: .tapKeyPad(Int(ProductivityViewReactor.MAX_TIME_INTERVAL - currentState.timer)))
            } else if currentState.timer + TimeInterval(time * Constants.Time.minute) > ProductivityViewReactor.MAX_TIME_INTERVAL {
                // Get max selectable time
                setSelectableTimeKey = .just(.setSelectableTime(.second))
            } else if currentState.timer + TimeInterval(time * Constants.Time.hour) > ProductivityViewReactor.MAX_TIME_INTERVAL {
                setSelectableTimeKey = .just(.setSelectableTime(.minute))
            } else {
                setSelectableTimeKey = .just(.setSelectableTime(.hour))
            }
            
            return .concat(setTime, setSelectableTimeKey)
        case .clear:
            // Clear the timer's end time
            timeSetInfo.timers[currentState.selectedIndexPath.row].endTime = 0
            
            let setTimer: Observable<Mutation> = .just(.setTimer(0))
            let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(currentState.sumOfTimers - currentState.timer))
            let setTime = mutate(action: .tapKeyPad(0))
            let sectionReload: Observable<Mutation> = .just(.sectionReload)
            
            return .concat(setTimer, setTime, setSumOfTimers, sectionReload)
        case let .tapTime(key):
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
            
            // Update the timer's end time
            timeSetInfo.timers[currentState.selectedIndexPath.row].endTime = timeInterval
            
            let setTimer: Observable<Mutation> = .just(.setTimer(timeInterval))
            let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(sumOfTimers + timeInterval))
            let setTime = mutate(action: .tapKeyPad(0))
            let sectionReload: Observable<Mutation> = .just(.sectionReload)
            
            return .concat(setTimer, setSumOfTimers, setTime, sectionReload)
        case .toggleTimeSetLoop:
            timeSetInfo.isLoop.toggle()
            return .just(.setTimeSetLoop(timeSetInfo.isLoop))
        case .addTimer:
            // Create default a timer (set 0)
            let index = timeSetInfo.timers.count + 1
            let info = TimerInfo(title: "\(index) 번째 타이머")
            // Add timer
            timeSetInfo.timers.append(info)
            
            let appendSectionItem: Observable<Mutation> = .just(.appendTimer(info))
            let setSelectIndexPath = mutate(action: .selectTimer(at: IndexPath(row: index - 1, section: 0)))
            let sectionReload: Observable<Mutation> = .just(.sectionReload)
            
            return .concat(appendSectionItem, setSelectIndexPath, sectionReload)
        case .deleteTimer:
            let index = currentState.selectedIndexPath.row
            guard index > 0 else { return .empty() }

            timeSetInfo.timers.remove(at: index)
            
            let removeTimer: Observable<Mutation> = .just(.removeTimer(at: index))
            let sectionReload: Observable<Mutation> = .just(.sectionReload)
            
            guard index < timeSetInfo.timers.count else {
                // Last timer deleted
                let setSelectIndexPath: Observable<Mutation> = mutate(action: .selectTimer(at: IndexPath(row: index - 1, section: 0)))
                return .concat(setSelectIndexPath, removeTimer, sectionReload)
            }
            
            let setTimerOptionVisible: Observable<Mutation> = .just(.setTimerOptionVisible(false))
            let setTimer: Observable<Mutation> = .just(.setTimer(timeSetInfo.timers[index].endTime))
            let setTime: Observable<Mutation> = .just(.setTime(0))
            
            return .concat(setTimerOptionVisible, setTimer, setTime, removeTimer, sectionReload)
        case let .moveTimer(at: sourceIndexPath, to: destinationIndexPath):
            // Swap timer
            timeSetInfo.timers.swapAt(sourceIndexPath.row, destinationIndexPath.row)
            
            let swapTimer: Observable<Mutation> = .just(.swapTimer(at: sourceIndexPath, to: destinationIndexPath))
            // Update selected index path
            var setSelectedIndexPath: Observable<Mutation>
            if currentState.selectedIndexPath == sourceIndexPath {
                setSelectedIndexPath = .just(.setSelectedIndexPath(destinationIndexPath))
            } else if currentState.selectedIndexPath == destinationIndexPath {
                setSelectedIndexPath = .just(.setSelectedIndexPath(sourceIndexPath))
            } else {
                setSelectedIndexPath = .empty()
            }
            let setTimeSetAction: Observable<Mutation> = .just(.setTimeSetAction(.Move))
            
            return .concat(swapTimer, setSelectedIndexPath, setTimeSetAction)
        case let .selectTimer(indexPath):
            var setTimerOptionVisible: Observable<Mutation> = .just(.setTimerOptionVisible(false))
            let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(indexPath))
            var setTimer: Observable<Mutation> = .empty()
            var setTime: Observable<Mutation> = .empty()
            let setTimeSetAction: Observable<Mutation> = .just(.setTimeSetAction(.Select))
            
            if currentState.selectedIndexPath == indexPath {
                // Toggle timer option visible. if current selected index path equal index path
                setTimerOptionVisible = .just(.setTimerOptionVisible(!currentState.isTimerOptionVisible))
            } else {
                // Update timer info to selected index path
                setTimer = .just(.setTimer(timeSetInfo.timers[indexPath.row].endTime))
                setTime = mutate(action: .tapKeyPad(0))
            }
            
            return .concat(setTimerOptionVisible, setSelectedIndexPath, setTimer, setTime, setTimeSetAction)
        case let .applyAlarm(alarm):
            timeSetInfo.timers.forEach { $0.alarm = alarm }
            return .just(.alert("알람이 전체 적용 되었습니다."))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        state.alert = nil
        state.timeSetAction = .None
        
        switch mutation {
        case let .setTime(time):
            state.time = time
            return state
        case let .setTimer(timeInterval):
            state.timer = timeInterval
            state.canTimeSetStart = state.timers.count > 1 || state.timer > 0
            return state
        case let .setSumOfTimers(timeInterval):
            state.sumOfTimers = timeInterval
            return state
        case let .setTimeSetLoop(isLoop):
            state.isTimeSetLoop = isLoop
            return state
        case let .appendTimer(info):
            state.timers.append(info)
            return state
        case let .removeTimer(at: index):
            state.timers.remove(at: index)
            return state
        case let .swapTimer(at: sourceIndexPath, to: destinationIndexPth):
            state.timers.swapAt(sourceIndexPath.row, destinationIndexPth.row)
            return state
        case let .setSelectedIndexPath(indexPath):
            state.selectedIndexPath = indexPath
            return state
        case let .setTimeSetAction(action):
            state.timeSetAction = action
            return state
        case let .setSelectableTime(time):
            state.selectableTime = time
            return state
        case let .setTimerOptionVisible(isVisible):
            state.isTimerOptionVisible = isVisible
            return state
        case let .alert(message):
            state.alert = message
            return state
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
}
