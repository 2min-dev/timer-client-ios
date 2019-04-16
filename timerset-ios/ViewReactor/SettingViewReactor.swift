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
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
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
     * - returns: setting menu section list
     */
    func initSettingMenus() -> Observable<[BaseTableSection]> {
        // add default menu
        var sections: [BaseTableSection] = []
        sections.append(BaseTableSection(title: "설정", items: [BaseTableItem(title: "앱 정보")]))
        
        // get laboratory menu is opened
        let laboratoryOpenedSections = appService.isLaboratoryOpened().map { isLaboratoryOpened -> [BaseTableSection] in
                // add developer menu, when isLaboratoryOpend is `true`
                if isLaboratoryOpened {
                    sections.append(BaseTableSection(title: "개발자 옵션", items: [BaseTableItem(title: "실험실")]))
                }
                
                return sections
            }
        
        return laboratoryOpenedSections
    }
}
