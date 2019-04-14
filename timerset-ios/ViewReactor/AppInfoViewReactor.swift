//
//  AppInfoViewReactor.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class AppInfoViewReactor: Reactor {
    // MARK: constants
    private let MAX_TAP_COUNT = 10
    
	enum Action {
        case tap
	}

	enum Mutation {
        case isLaboratoryOpend(Bool)
	}

	struct State {
        var isLaboratoryOpened: Bool
	}

	// MARK: properties
	var initialState: State
    private let appService: AppServicePorotocol
    
    private var disposeBag = DisposeBag()
    
    var tapCount: Int = 0
    
    init(appService: AppServicePorotocol) {
		self.initialState = State(isLaboratoryOpened: false)
        self.appService = appService
        
        appService.getIsLaboratoryOpened()
            .subscribe(onNext: {
                self.initialState.isLaboratoryOpened = $0
            })
            .disposed(by: disposeBag)
	}

	func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tap:
            // no action when laboratory menu was opened already
            guard !currentState.isLaboratoryOpened else { return Observable.empty() }
            tapCount += 1
            
            Logger.debug("developer mode : \(tapCount) / \(MAX_TAP_COUNT)")
            // if tap count equal `MAX_TAP_COUNT`, open laboratory menu
            if tapCount == MAX_TAP_COUNT {
                appService.setIsLaboratoryOpened(isOpened: true)
                return Observable.just(Mutation.isLaboratoryOpend(true))
            }
            return Observable.empty()
        }
	}

	func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .isLaboratoryOpend(isOpened):
            state.isLaboratoryOpened = isOpened
            return state
        }
	}
} 
