//
//  SharedTimeSetViewController.swift
//  timer
//
//  Created by JSilver on 2019/07/06.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class SharedTimeSetViewController: BaseViewController, View {
    // MARK: - view properties
    private var sharedTimeSetView: SharedTimeSetView { return view as! SharedTimeSetView }
    
    // MARK: - properties
    var coordinator: SharedTimeSetViewCoordinator
    
    // MARK: - constructor
    init(coordinator: SharedTimeSetViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = SharedTimeSetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bind
    func bind(reactor: SharedTimeSetViewReactor) {
        // MARK: action
        
        // MARK: state
    }
    
    deinit {
        Logger.verbose()
    }
}
