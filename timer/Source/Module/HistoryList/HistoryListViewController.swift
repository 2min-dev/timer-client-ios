//
//  HistoryListViewController.swift
//  timer
//
//  Created by JSilver on 2019/10/13.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class HistoryListViewController: BaseViewController, View {
    // MARK: - view properties
    private var historyListView: HistoryListView { return view as! HistoryListView }
    
    // MARK: - properties
    var coordinator: HistoryListViewCoordinator
    
    // MARK: - constructor
    init(coordinator: HistoryListViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = HistoryListView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: HistoryListViewReactor) {
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
