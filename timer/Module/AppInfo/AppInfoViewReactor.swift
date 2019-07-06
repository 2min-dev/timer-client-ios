//
//  AppInfoViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class AppInfoViewReactor: Reactor {
	enum Action {

	}

	enum Mutation {
        
	}

	struct State {
        
	}

	// MARK: properties
	var initialState: State
    
    private var disposeBag = DisposeBag()
    
    init() {
		self.initialState = State()
	}

	func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
	}

	func reduce(state: State, mutation: Mutation) -> State {
        return state
	}
} 
