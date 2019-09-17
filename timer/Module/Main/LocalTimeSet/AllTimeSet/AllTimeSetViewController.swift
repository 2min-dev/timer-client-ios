//
//  AllTimeSetViewController.swift
//  timer
//
//  Created by JSilver on 18/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class AllTimeSetViewController: BaseViewController, View {
    // MARK: - view properties
    private var allTimeSetView: AllTimeSetView { return view as! AllTimeSetView }
    
    private var headerView: CommonHeader { return allTimeSetView.headerView }
    
    // MARK: - properties
    var coordinator: AllTimeSetViewCoordinator
    
    // MARK: - constructor
    init(coordinator: AllTimeSetViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = AllTimeSetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: AllTimeSetViewReactor) {
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
