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
                SettingItem(title: "공지사항", subtitle: nil),
                SettingItem(title: "기본 사운드 설정", subtitle: "현재 : 기본음"),
                SettingItem(title: "카운트 다운", subtitle: "현재 : \(countdown)초"),
                SettingItem(title: "제작팀 정보", subtitle: nil),
                SettingItem(title: "오픈소스 라이센스", subtitle: nil)
            ])
        ]))
    }
    
    deinit {
        Logger.verbose()
    }
}
