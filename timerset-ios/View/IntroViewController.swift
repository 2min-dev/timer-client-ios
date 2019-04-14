//
//  IntroViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class IntroViewController: BaseViewController, View {
    // MARK: view properties
    private var introView: IntroView { return self.view as! IntroView }
    
    // MARK: properties
    var coordinator: IntroViewCoordinator!
    
    // MARK: ### lifecycle ###
    override func loadView() {
        self.view = IntroView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: ### reactor bind ###
    func bind(reactor: IntroViewReactor) {
        reactor.action.onNext(.viewDidLoad)
        
        // MARK: state
        reactor.state
            .map { $0.isDone }
            .filter { $0 }
            .distinctUntilChanged()
            .subscribe({ [weak self] _ in
                self?.coordinator.present(for: .timerSet)
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        Logger.verbose("")
    }
}
