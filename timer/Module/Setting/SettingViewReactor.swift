//
//  SettingViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class SettingViewReactor: Reactor {
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case setSections([SettingSectionModel])
    }
    
    struct State {
        var sections: [SettingSectionModel]
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServicePorotocol
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(appService: AppServicePorotocol) {
        self.appService = appService
        initialState = State(sections: [])
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return actionViewDidLoad()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setSections(sections):
            state.sections = sections
            return state
        }
    }
    
    // MARK: - action method
    private func actionViewDidLoad() -> Observable<Mutation> {
        let countdown = appService.getCountdown()
        
        return .just(.setSections(
            [SettingSectionModel(model: Void(), items: [
                .notice,
                .alarm("기본음"),
                .countdown(countdown),
                .teamInfo,
                .license
            ])
        ]))
    }
    
    deinit {
        Logger.verbose()
    }
}
