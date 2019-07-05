//
//  CreateTimerSetViewController.swift
//  timer
//
//  Created by JSilver on 19/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class CreateTimerSetViewController: BaseViewController, View {
    // MARK: - view properties
    private var createTimerSetView: CreateTimerSetView { return self.view as! CreateTimerSetView }
    
    // MARK: - properties
    var coordinator: CreateTimerSetViewCoordinator!
    
    // MARK: - lifecycle
    override func loadView() {
        self.view = CreateTimerSetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - reactor bind
    func bind(reactor: CreateTimerSetViewReactor) {
        // MARK: action
        
        // MARK: state
    }
    
    deinit {
        Logger.verbose()
    }
}
