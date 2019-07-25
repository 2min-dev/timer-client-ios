//
//  TimerOptionViewController.swift
//  timer
//
//  Created by JSilver on 25/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimerOptionViewController: BaseViewController, View {
    // MARK: - view properties
    private var timerOptionView: TimerOptionView { return self.view as! TimerOptionView }
    
    // MARK: - properties
    var coordinator: TimerOptionViewCoordinator!
    
    // MARK: - lifecycle
    override func loadView() {
        self.view = TimerOptionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: TimerOptionViewReactor) {
        // MARK: action
        
        // MARK: state
    }
    
    // MARK: - priate method
    
    // MARK: - public method
    
    deinit {
        Logger.verbose()
    }
}
