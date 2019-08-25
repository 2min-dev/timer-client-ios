//
//  TimeSetMemoViewController.swift
//  timer
//
//  Created by JSilver on 25/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimeSetMemoViewController: BaseViewController, View {
    // MARK: - view properties
    private var timeSetMemoView: TimeSetMemoView { return view as! TimeSetMemoView }
    
    // MARK: - properties
    var coordinator: TimeSetMemoViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TimeSetMemoViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetMemoView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetMemoViewReactor) {
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
