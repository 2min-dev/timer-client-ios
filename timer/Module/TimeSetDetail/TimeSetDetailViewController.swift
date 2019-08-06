//
//  TimeSetDetailViewController.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimeSetDetailViewController: BaseViewController, View {
    // MARK: - view properties
    private var timeSetDetailView: TimeSetDetailView { return view as! TimeSetDetailView }
    
    // MARK: - properties
    var coordinator: TimeSetDetailViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TimeSetDetailViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetDetailView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetDetailViewReactor) {
        // MARK: action
        
        // MARK: state
    }
    
    // MARK: - priate method
    
    // MARK: - public method
    
    deinit {
        Logger.verbose()
    }
}
