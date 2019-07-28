//
//  AlarmChangeViewReactor.swift
//  timer
//
//  Created by JSilver on 27/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit
import RxDataSources

typealias AlarmSectionModel = SectionModel<Void, String>

class AlarmChangeViewReactor: Reactor {
    enum Action {
        case viewDidLoad
        case viewWillAppear
        case selectAlarm(at: IndexPath)
    }
    
    enum Mutation {
        case setAlarm(String)
        case setSections([AlarmSectionModel])
        case setSelectedIndexPath(at: IndexPath)
        
        case sectionReload
    }
    
    struct State {
        var alarm: String                       // Current alarm
        var sections: [AlarmSectionModel]       // The section of alarms
        var selectedIndexPath: IndexPath?       // Current selected index path
        
        var shouldSectionReload: Bool           // Need section reload
    }
    
    // MARK: - properties
    var initialState: State
    
    // MARK: - constructor
    init(alarm: String) {
        self.initialState = State(alarm: alarm,
                                  sections: [AlarmSectionModel(model: Void(), items: [])],
                                  selectedIndexPath: nil,
                                  shouldSectionReload: true)
    }
    
    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            // Load alarm list
            return getAlarms()
                .flatMap { alarms -> Observable<Mutation> in
                    // Create section model from alarm list
                    let sections = [AlarmSectionModel(model: Void(), items: alarms)]
                    
                    let setSections: Observable<Mutation> = .just(.setSections(sections))
                    let sectionReload: Observable<Mutation> = .just(.sectionReload)
                
                    return .concat(setSections, sectionReload)
                }
        case .viewWillAppear:
            // Set selected index path to current alarm
            if let index = currentState.sections[0].items.firstIndex(of: currentState.alarm) {
                return .just(.setSelectedIndexPath(at: IndexPath(row: index, section: 0)))
            }
            
            return .empty()
        case let .selectAlarm(at: indexPath):
            // Change selected index path
            let alarm = currentState.sections[0].items[indexPath.row]
            
            let setAlarm: Observable<Mutation> = .just(.setAlarm(alarm))
            let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(at: indexPath))
            
            return .concat(setAlarm, setSelectedIndexPath)
        }
     }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setAlarm(alarm):
            state.alarm = alarm
            return state
        case let .setSections(sections):
            state.sections = sections
            return state
        case let .setSelectedIndexPath(at: IndexPath):
            state.selectedIndexPath = IndexPath
            return state
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - private method
    // MARK: Temporary get method about alarm list observable. remove it (required)
    private func getAlarms() -> Observable<[String]> {
        let alarms = [
            "시스템 알람",
            "경쾌한 알람",
            "신나는 알람",
            "우울한 알람",
            "그냥 알람",
            "알람미",
            "핑-퐁",
            "띠-용",
            "삐-용"
        ]
        
        return .just(alarms)
    }
}
