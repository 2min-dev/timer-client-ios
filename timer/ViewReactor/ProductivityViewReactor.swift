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
        
        case appendSectionItem(ProductivityTimerSection.Item)
        case setSelectedIndexPath(IndexPath)
    }
    
    struct State {
        var time: Int
        var timer: TimeInterval
        
        var sections: [ProductivityTimerSection]
        var selectedIndexPath: IndexPath?
        
        var shouldStartTimer: Bool
        var shouldReloadSection: Bool
    }
    
    // MARK: properties
    var initialState: State
    private let timerService: TimerSetServicePorotocol
    let timerSet: TimerSet // Default timer set
    
    private var disposeBag = DisposeBag()
    
    init(timerService: TimerSetServicePorotocol) {
        self.initialState = State(time: 0,
                                  timer: 0,
                                  sections: [ProductivityTimerSection(model: Void(), items: [])],
                                  selectedIndexPath: nil,
                                  shouldStartTimer: false,
                                  shouldReloadSection: true)
        self.timerService = timerService
        self.timerSet = TimerSet(info: TimerSetInfo(name: "", description: ""))
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
        case .addTimer:
            let items = currentState.sections[0].items
            let info = TimerInfo(title: "\(items.count + 1)번 째 타이머", endTime: currentState.timer)
            
            let appendSectionItem = timerSet.createTimer(info: info)
                                            .map { Mutation.appendSectionItem(ProductivityTimerCollectionViewCellReactor(info: $0.info, index: items.count + 1)) }
            
            let clearTimer = mutate(action: .clearTimer)
            
            return Observable.concat(appendSectionItem, clearTimer)
        case let .timerSelected(indexPath):
            if let oldIndexPath = currentState.selectedIndexPath {
                let previousItem = currentState.sections[0].items[oldIndexPath.row]
                previousItem.action.onNext(.select(false))
            }
            
            let item = currentState.sections[0].items[indexPath.row]
            item.action.onNext(.select(true))
            
            return Observable.concat(Observable.just(Mutation.setSelectedIndexPath(indexPath)),
                                     Observable.just(Mutation.setTimer(item.currentState.time)))
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
            state.timer = timeInterval
            
            state.shouldStartTimer = state.sections[0].items.count > 0 || state.timer > 0
            return state
        case let .appendSectionItem(reactor):
            state.sections[0].items.append(reactor)
            
            state.shouldStartTimer = true
            state.shouldReloadSection = true
            return state
        case let .setSelectedIndexPath(indexPath):
            state.selectedIndexPath = indexPath
            return state
        }
    }
}
