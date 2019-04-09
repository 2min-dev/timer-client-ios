//
//  IntroViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit

class IntroViewController: BaseViewController, View {
    // MARK: view properties
    private unowned var loginView: IntroView { return self.view as! IntroView }
    
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
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator.present(for: .main)
            })
            .disposed(by: disposeBag)
    }
}
