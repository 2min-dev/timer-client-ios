//
//  TeamInfoViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TeamInfoViewReactor: Reactor {
	enum Action {

	}

	enum Mutation {
        
	}

	struct State {
        
	}

	// MARK: - properties
	var initialState: State
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init() {
		initialState = State()
	}
    
    deinit {
        Logger.verbose()
    }
} 
