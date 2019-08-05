//
//  AlarmChangeViewController.swift
//  timer
//
//  Created by JSilver on 26/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources

class AlarmChangeViewController: BaseViewController, View {
    // MARK: - view properties
    private var alarmChangeView: AlarmChangeView { return view as! AlarmChangeView }
    
    private var backButton: UIButton { return alarmChangeView.backButton }
    private var currentAlarmLabel: UILabel { return alarmChangeView.currentAlarmLabel }
    
    private var alarmTableView: UITableView { return alarmChangeView.alarmTableView }
    
    // MAKR: - properties
    private let dataSource = RxTableViewSectionedReloadDataSource<AlarmSectionModel>(configureCell: { _, tableView, indexPath, alarm -> AlarmChangeTableViewCell in
        let cell = tableView.dequeueReusableCell(withIdentifier: AlarmChangeTableViewCell.ReuseableIdentifier, for: indexPath) as! AlarmChangeTableViewCell
        cell.nameLabel.text = alarm
        return cell
    })
    
    // MARK: - lifecycle
    override func loadView() {
        view = AlarmChangeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bind
    func bind(reactor: AlarmChangeViewReactor) {
        // MARK: action
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in self.navigationController?.popViewController(animated: true) })
            .disposed(by: disposeBag)
        
        alarmTableView.rx.itemSelected
            .map { Reactor.Action.selectAlarm(at: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        // Alarm section
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .bind(to: alarmTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // Current alarm
        reactor.state
            .map { $0.alarm }
            .distinctUntilChanged()
            .map { String(format: "alarm_change_current_title_format".localized, $0) }
            .bind(to: currentAlarmLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Selected alarm
        reactor.state
            .map { $0.selectedIndexPath }
            .filter { $0 != nil }
            .map { $0! }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.selectAlarm(at: $0) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    private func selectAlarm(at indexPath: IndexPath) {
        alarmTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    
    deinit {
        Logger.verbose()
    }
}

extension Reactive where Base: AlarmChangeViewController {
    // MARK: - control event
    var alarmSelected: ControlEvent<String> {
        let source = base.reactor!.state
            .map { $0.alarm }
            .distinctUntilChanged()
        
        return ControlEvent(events: source)
    }
}
