//
//  TimerOptionMainViewController.swift
//  timer
//
//  Created by JSilver on 25/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimerOptionMainViewController: BaseViewController, View {
    // MARK: - view properties
    private var timerOptionView: TimerOptionMainView { return self.view as! TimerOptionMainView }
    
    // MARK: - properties
    var coordinator: TimerOptionMainViewCoordinator!
    
    // MARK: - lifecycle
    override func loadView() {
        self.view = TimerOptionMainView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: TimerOptionMainViewReactor) {
        // MARK: action
        
        // MARK: state
    }
    
    // MARK: - priate method
    
    // MARK: - public method
    
    deinit {
        Logger.verbose()
    }
}
