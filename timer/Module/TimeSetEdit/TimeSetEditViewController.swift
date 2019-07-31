//
//  TimeSetEditViewController.swift
//  timer
//
//  Created by JSilver on 31/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimeSetEditViewController: BaseViewController, View {
    // MARK: - view properties
    private var timeSetEditView: TimeSetEditView { return self.view as! TimeSetEditView }
    
    // MARK: - properties
    var coordinator: TimeSetEditViewCoordinator!
    
    // MARK: - lifecycle
    override func loadView() {
        self.view = TimeSetEditView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetEditViewReactor) {
        // MARK: action
        
        // MARK: state
    }
    
    // MARK: - priate method
    
    // MARK: - public method
    
    deinit {
        Logger.verbose()
    }
}
