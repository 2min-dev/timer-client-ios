//
//  NoticeListViewController.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class NoticeListViewController: BaseViewController, View {
    // MARK: - view properties
    private var noticeListView: NoticeListView { return view as! NoticeListView }
    
    // MARK: - properties
    var coordinator: NoticeListViewCoordinator
    
    // MARK: - constructor
    init(coordinator: NoticeListViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = NoticeListView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: NoticeListViewReactor) {
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
