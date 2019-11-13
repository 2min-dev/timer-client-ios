//
//  AlarmSettingViewController.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class AlarmSettingViewController: BaseHeaderViewController, View {
    // MARK: - view properties
    private var alarmSettingView: AlarmSettingView { return view as! AlarmSettingView }
    
    override var headerView: CommonHeader { return alarmSettingView.headerView }
    
    private var alarmSettingTableView: UITableView { return alarmSettingView.alarmTableView }
    
    // MARK: - properties
    var coordinator: AlarmSettingViewCoordinator
    
    private let dataSource = RxTableViewSectionedReloadDataSource<AlarmSettingSectionModel>(configureCell: { (datasource, tableView, indexPath, item) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmSettingTableViewCell.name, for: indexPath) as? AlarmSettingTableViewCell else { return UITableViewCell() }
        
        cell.titleLabel.text = item.title
        
        return cell
    })
    
    // MARK: - constructor
    init(coordinator: AlarmSettingViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = AlarmSettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell
        alarmSettingTableView.register(AlarmSettingTableViewCell.self, forCellReuseIdentifier: AlarmSettingTableViewCell.name)
    }
    
    // MARK: - bine
    override func bind() {
        super.bind()
        
        alarmSettingTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: AlarmSettingViewReactor) {
        // MARK: action
        rx.viewDidLoad
            .map { Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        alarmSettingTableView.rx.itemSelected
            .map { Reactor.Action.select($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .bind(to: alarmSettingTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedIndexPath }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.alarmSettingTableView.selectRow(at: $0, animated: true, scrollPosition: .none) })
            .disposed(by: disposeBag)
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - alarm setting datasource
typealias AlarmSettingSectionModel = SectionModel<Void, Alarm>
