//
//  SettingViewReactor.swift
//  timerset-ios
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
    
    func mutate(appEvent: AppEvent) -> Observable<Mutation> {
        switch appEvent {
        case .isLaboratoryOpened:
            return initSettingMenus().map { Mutation.setSections($0) }
        }
    }
    
    func transform(mutation: Observable<SettingViewReactor.Mutation>) -> Observable<SettingViewReactor.Mutation> {
        return Observable.merge(mutation, appService.event.flatMap { self.mutate(appEvent: $0) })
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
     *
     * - returns: setting menu section list
     */
    func initSettingMenus() -> Observable<[BaseTableSection]> {
        // get laboratory menu is opened
        return appService.getIsLaboratoryOpened()
            .map {
                var sections: [BaseTableSection] = []
                // add default menu
                sections.append(BaseTableSection(title: "설정", items: [BaseTableItem(title: "앱 정보")]))
                
                // add developer menu, when isLaboratoryOpend is `true`
                if $0 {
                    sections.append(BaseTableSection(title: "개발자 옵션", items: [BaseTableItem(title: "실험실")]))
                }
                
                return sections
            }
    }
}
