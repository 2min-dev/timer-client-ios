//
//  AppInfoViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class AppInfoViewController: BaseViewController, View {
	// MARK: view properties
	private var appInfoView: AppInfoView { return self.view as! AppInfoView }
	
	// MARK: properties
	var coordinator: AppInfoCoordinator!

	// MARK: lifecycle
	override func loadView() {
		self.view = AppInfoView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(recognizer:)))
        appInfoView.addGestureRecognizer(gesture)
	}

	// MARK: reactor bind
	func bind(reactor: AppInfoViewReactor) {
		// MARK: action

		// MARK: state
        reactor.state
            .map { $0.isLaboratoryOpened }
            .skip(1) // skip initialState
            .filter { $0 == true }
            .subscribe(onNext: { _ in
                Logger.debug("laboratory was opened.")
            })
            .disposed(by: disposeBag)
	}
    
    deinit {
        Logger.verbose("")
    }
    
    // MARK: gesture methods
    @objc private func tapGesture(recognizer: UITapGestureRecognizer) {
        reactor?.action.onNext(.tap)
    }
} 
