//
//  IntroViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class IntroViewReactor: Reactor {
    enum IntroState {
        case none
        case done
        case running
    }
    
    enum Action {
        case viewWillAppear
    }
    
    enum Mutation {
        case setIntroState(IntroState)
    }
    
    struct State {
        var introState: IntroState
    }
    
    // MARK: properties
    var initialState: IntroViewReactor.State
    private let appService: AppServiceProtocol
    private let timeSetService: TimeSetServiceProtocol
    
    init(appService: AppServiceProtocol, timeSetService: TimeSetServiceProtocol) {
        self.appService = appService
        self.timeSetService = timeSetService
        initialState = State(introState: .none)
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setIntroState(introState):
            state.introState = introState
            return state
        }
    }
    
    // MARK: - action method
    private func actionViewWillAppear() -> Observable<Mutation> {
        Logger.info("""
            app launched.
            - title(\(Constants.appTitle ?? ""))
            - version(\(Constants.appVersion ?? ""))
            - build(\(Constants.appBuild ?? ""))
            - device version(\(Constants.deviceVersion))
            """)
        
        if let backgroundDate = appService.getBackgroundDate(),
            let timeSet = timeSetService.restoreTimeSet() {
            let passedTime = Date().timeIntervalSince1970 - backgroundDate.timeIntervalSince1970
            
            timeSet.consume(time: passedTime)
            timeSet.start()
            
            return .just(.setIntroState(.running))
        }
        
        return .just(.setIntroState(.done))
    }
    
    deinit {
        Logger.verbose()
    }
}
