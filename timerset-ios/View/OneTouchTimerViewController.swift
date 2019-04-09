//
//  OneTouchTimerViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class OneTouchTimerViewController: BaseViewController, View {
    // MARK: view properties
    private unowned var timerSetView: OneTouchTimerView { return self.view as! OneTouchTimerView }
    
    // MARK: properties
    var coordinator: OneTouchTimerViewCoordinator!
    
    // MARK: ### lifecycle ###
    override func loadView() {
        self.view = OneTouchTimerView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: ### reactor bind ###
    func bind(reactor: OneTouchTimerViewReactor) {
        // MARK: action
        
        // MARK: state
    }
}
