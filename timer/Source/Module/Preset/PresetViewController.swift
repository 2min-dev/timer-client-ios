//
//  PresetViewController.swift
//  timer
//
//  Created by JSilver on 2019/11/30.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class PresetViewController: BaseViewController, View {
    // MARK: - view properties
    private var presetView: PresetView { view as! PresetView }
    
    // MARK: - properties
    var coordinator: PresetViewCoordinator
    
    // MARK: - constructor
    init(coordinator: PresetViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = PresetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: PresetViewReactor) {
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
