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

class IntroViewController: BaseViewController, View {
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
        reactor.action.onNext(.viewDidLoad)
        
        // MARK: state
        reactor.state
            .map { $0.isDone }
            .filter { $0 }
            .distinctUntilChanged()
            .subscribe({ [weak self] _ in _ = self?.coordinator.present(for: .main) })
            .disposed(by: disposeBag)
    }
    
    deinit {
        Logger.verbose()
    }
}
