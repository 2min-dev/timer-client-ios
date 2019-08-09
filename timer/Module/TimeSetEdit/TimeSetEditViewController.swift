//
//  TimeSetEditViewController.swift
//  timer
//
//  Created by JSilver on 09/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimeSetEditViewController: BaseViewController, View {
    // MARK: - view properties
    private var timeSetEditView: TimeSetEditView { return view as! TimeSetEditView }
    
    // MARK: - properties
    var coordinator: TimeSetEditViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TimeSetEditViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetEditView()
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
