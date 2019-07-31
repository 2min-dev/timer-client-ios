//
//  LocalTimeSetViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class LocalTimeSetViewController: BaseViewController, View {
    // MARK: - view properties
    private var localTimeSetView: LocalTimeSetView { return view as! LocalTimeSetView }
    
    // MARK: - properties
    var coordinator: LocalTimeSetViewCoordinator
    
    // MARK: - constructor
    init(coordinator: LocalTimeSetViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = LocalTimeSetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bind
    func bind(reactor: LocalTimeSetViewReactor) {
        // MARK: action
        
        // MARK: state
    }
    
    deinit {
        Logger.verbose()
    }
}
