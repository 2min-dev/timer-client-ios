//
//  AlarmSettingViewReactor.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class AlarmSettingViewReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServicePorotocol
    
    // MARK: - constructor
    init(appService: AppServicePorotocol) {
        self.appService = appService
        initialState = State()
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
    
    // MARK: - action method
    // MARK: - priate method
    // MARK: - public method
    
    deinit {
        Logger.verbose()
    }
}
