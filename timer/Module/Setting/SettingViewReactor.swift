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
        case setSections([CommonTableSection])
    }
    
    struct State {
        var sections: [CommonTableSection]
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServicePorotocol
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(appService: AppServicePorotocol) {
        self.initialState = State(sections: [])
        self.appService = appService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return initSettingMenus().map { Mutation.setSections($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setSections(sections):
            state.sections = sections
            return state
        }
    }
    
    /**
     * initialize setting menu
     * - returns: setting menu section list
     */
    func initSettingMenus() -> Observable<[CommonTableSection]> {
        // add default menu
        var sections: [CommonTableSection] = []
        sections.append(CommonTableSection(title: "설정", items: [CommonTableItem(title: "앱 정보")]))
    
        return .just(sections)
    }
}
