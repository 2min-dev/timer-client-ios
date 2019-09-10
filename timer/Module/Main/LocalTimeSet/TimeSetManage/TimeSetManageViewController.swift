//
//  TimeSetManageViewController.swift
//  timer
//
//  Created by JSilver on 10/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimeSetManageViewController: BaseViewController, View {
    // MARK: - view properties
    private var timeSetManageView: TimeSetManageView { return view as! TimeSetManageView }
    
    // MARK: - properties
    var coordinator: TimeSetManageViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TimeSetManageViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetManageView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetManageViewReactor) {
        // MARK: action
        
        // MARK: state
    }
    
    // MARK: - action method
    // MARK: - state method
    
    // MARK: - priate method
    // MARK: - public method
    
    deinit {
        Logger.verbose()
    }
}
