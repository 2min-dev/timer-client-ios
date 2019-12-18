//
//  IntroViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UserNotifications
import UIKit
import RxSwift
import ReactorKit

class IntroViewController: BaseViewController, ViewControllable, View {
    // MARK: - view properties
    private var introView: IntroView { return view as! IntroView }
    
    // MARK: - properties
    var coordinator: IntroViewCoordinator
    
    // MARK: - constructor
    init(coordinator: IntroViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = IntroView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (didAllow, error) in
            Logger.debug("allowed")
        }
    }
    
    // MARK: - bind
    func bind(reactor: IntroViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .map { $0.introState }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.presentByState($0) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - state method
    private func presentByState(_ state: IntroViewReactor.IntroState) {
        switch state {
        case .done:
            _ = coordinator.present(for: .main, animated: true)
            
        case .running:
            _ = coordinator.present(for: .timeSetProcess, animated: true)
            
        case .none:
            break
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
