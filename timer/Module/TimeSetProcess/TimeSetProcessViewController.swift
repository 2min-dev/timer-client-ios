//
//  TimeSetProcessViewController.swift
//  timer
//
//  Created by JSilver on 12/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimeSetProcessViewController: BaseViewController, View {
    // MARK: - view properties
    private var timeSetProcessView: TimeSetProcessView { return view as! TimeSetProcessView }
    
    // MARK: - properties
    var coordinator: TimeSetProcessViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TimeSetProcessViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetProcessView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetProcessViewReactor) {
        // MARK: action
        
        // MARK: state
    }
    
    // MARK: - action method
    
    // MARK: - state method
    
    deinit {
        Logger.verbose()
    }
}
