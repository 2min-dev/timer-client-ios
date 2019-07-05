//
//  TimerSetViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class TimerSetListViewController: BaseViewController, View {
    // MARK: - view properties
    private var timerSetView: TimerSetView { return self.view as! TimerSetView }
    private var timerSetTableView: UITableView { return timerSetView.tableView }
    
    // MARK: - properties
    var coordinator: TimerSetListViewCoordinator!
    
    // MARK: - lifecycle
    override func loadView() {
        self.view = TimerSetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerSetTableView.register(TimerSetTableViewCell.self, forCellReuseIdentifier: "TimerSetTableViewCell")
    }
    
    // MARK: - reactor bind
    func bind(reactor: TimerSetListViewReactor) {
        // MARK: action
        reactor.action.onNext(.viewDidLoad)
        
        // MARK: state
        reactor.state
            .map { $0.timerSets }
            .bind(to: timerSetTableView.rx.items(cellIdentifier: "TimerSetTableViewCell")) { (index, timerSet, cell) in
                guard let cell = cell as? TimerSetTableViewCell else { return }
                cell.reactor = TimerSetTableViewCellReactor(timerSet: timerSet)
            }
            .disposed(by: disposeBag)
    }
    
    deinit {
        Logger.verbose("")
    }
}
