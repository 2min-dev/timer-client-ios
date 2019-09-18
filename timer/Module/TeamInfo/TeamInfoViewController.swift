//
//  TeamInfoViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TeamInfoViewController: BaseViewController, View {
	// MARK: - view properties
	private var teamInfoView: TeamInfoView { return view as! TeamInfoView }
	
	// MARK: - properties
	var coordinator: TeamInfoViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TeamInfoViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	// MARK: - lifecycle
	override func loadView() {
		view = TeamInfoView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - bind
	func bind(reactor: TeamInfoViewReactor) {
		// MARK: action

		// MARK: state
	}
    
    deinit {
        Logger.verbose()
    }
} 
