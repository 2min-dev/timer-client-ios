//
//  ProductivityViewReactor.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit
import RxDataSources

typealias SideTimerListSection = SectionModel<Void, SideTimerTableViewCellReactor>

class ProductivityViewReactor: Reactor {
    enum Action {
        case updateTimeInput(Int)
        case tapTimeKey(ProductivityView.TimeKey)
        case clearTimer
        case toggleLoop
        case toggleVibrationAlert
        case addTimer
        case timerSelected(IndexPath)
    }
    
    enum Mutation {
        case setTime(Int)
        case setTimer(TimeInterval)
        case setLoop(Bool)
        case setVibrationAlert(Bool)
        
        case appendSectionItem(SideTimerListSection.Item)
        case setSelectedIndexPath(IndexPath)
    }
    
    struct State {
        var time: Int
        var timer: TimeInterval
        var loop: Bool
        var vibationAlert: Bool
        
        var sections: [SideTimerListSection]
        var selectedIndexPath: IndexPath?
    }
    
    // MARK: properties
    var initialState: State
    private let timerService: TimerSetServicePorotocol
    
    init(timerService: TimerSetServicePorotocol) {
        self.initialState = State(time: 0,
                                  timer: 0,
                                  loop: false,
                                  vibationAlert: false,
                                  sections: [SideTimerListSection(model: Void(), items: [])],
                                  selectedIndexPath: nil)
        self.timerService = timerService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateTimeInput(time):
            return Observable.just(Mutation.setTime(time))
        case let .tapTimeKey(key):
            var timeInterval = currentState.timer
            switch key {
            case .hour:
                timeInterval += Double(currentState.time * Constants.Time.hour)
            case .minute:
                timeInterval += Double(currentState.time * Constants.Time.minute)
            case .second:
                timeInterval += Double(currentState.time)
            }
            return Observable.concat(Observable.just(Mutation.setTimer(timeInterval)), Observable.just(Mutation.setTime(0)))
        case .clearTimer:
            return Observable.concat(Observable.just(Mutation.setTimer(0)), Observable.just(Mutation.setTime(0)))
        case .toggleLoop:
            return Observable.just(Mutation.setLoop(!currentState.loop))
        case .toggleVibrationAlert:
            return Observable.just(Mutation.setVibrationAlert(!currentState.vibationAlert))
        case .addTimer:
            let items = currentState.sections[0].items
            let reactor = SideTimerTableViewCellReactor(info: TimerInfo(title: "\(items.count + 1)번 째 타이머", endTime: currentState.timer))
            return Observable.concat(Observable.just(Mutation.appendSectionItem(reactor)),
                                     Observable.just(Mutation.setSelectedIndexPath(IndexPath(row: items.count + 1, section: 0))),
                                     mutate(action: .clearTimer))
        case let .timerSelected(indexPath):
//            let item = currentState.sections[0].items[indexPath.row]
//            return Observable.concat(Observable.just(Mutation.setSelectedIndexPath(indexPath)),
//                                     Observable.just(Mutation.setTimer(item.currentState.time)))
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setTime(time):
            state.time = time
            return state
        case let .setTimer(timeInterval):
            state.timer = timeInterval
            return state
        case let .setLoop(loop):
            state.loop = loop
            return state
        case let .setVibrationAlert(vibrationAlert):
            state.vibationAlert = vibrationAlert
            return state
        case let .appendSectionItem(reactor):
            state.sections[0].items.append(reactor)
            return state
        case let .setSelectedIndexPath(indexPath):
            state.selectedIndexPath = indexPath
            return state
        }
    }
}
