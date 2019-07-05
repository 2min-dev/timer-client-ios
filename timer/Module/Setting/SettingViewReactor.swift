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
        case setSections([BaseTableSection])
    }
    
    struct State {
        var sections: [BaseTableSection]
    }
    
    // MARK: properties
    var initialState: State
    private let appService: AppServicePorotocol
    
    private var disposeBag = DisposeBag()
    
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
    func initSettingMenus() -> Observable<[BaseTableSection]> {
        // add default menu
        var sections: [BaseTableSection] = []
        sections.append(BaseTableSection(title: "설정", items: [BaseTableItem(title: "앱 정보")]))
    
        return .just(sections)
    }
}
