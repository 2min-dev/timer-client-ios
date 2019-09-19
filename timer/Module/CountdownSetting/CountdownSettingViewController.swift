//
//  CountdownSettingViewController.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class CountdownSettingViewController: BaseViewController, View {
    // MARK: - view properties
    private var countdownSettingView: CountdownSettingView { return view as! CountdownSettingView }
    
    private var headerView: CommonHeader { return countdownSettingView.headerView }
    
    // MARK: - properties
    var coordinator: CountdownSettingViewCoordinator
    
    // MARK: - constructor
    init(coordinator: CountdownSettingViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = CountdownSettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: CountdownSettingViewReactor) {
        // MARK: action
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.headerActionHandler(type: $0) })
            .disposed(by: disposeBag)
        
        // MARK: state
    }
    
    // MARK: - action method
    /// Handle header button tap action according to button type
    private func headerActionHandler(type: CommonHeader.ButtonType) {
        switch type {
        case .back:
            navigationController?.popViewController(animated: true)

        default:
            break
        }
    }
    
    // MARK: - state method
    
    deinit {
        Logger.verbose()
    }
}
