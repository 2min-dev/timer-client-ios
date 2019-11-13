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
import RxDataSources

class CountdownSettingViewController: BaseHeaderViewController, View {
    // MARK: - view properties
    private var countdownSettingView: CountdownSettingView { return view as! CountdownSettingView }
    
    override var headerView: CommonHeader { return countdownSettingView.headerView }
    
    private var countdownSettingTableView: UITableView { return countdownSettingView.countdownTableView }
    
    // MARK: - properties
    var coordinator: CountdownSettingViewCoordinator
    
    private let dataSource = RxTableViewSectionedReloadDataSource<CountdownSettingSectionModel>(configureCell: { (datasource, tableView, indexPath, item) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountdownSettingTableViewCell.name, for: indexPath) as? CountdownSettingTableViewCell else { return UITableViewCell() }
        
        cell.titleLabel.text = item.title
        
        return cell
    })
    
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
        // Register cell
        countdownSettingTableView.register(CountdownSettingTableViewCell.self, forCellReuseIdentifier: CountdownSettingTableViewCell.name)
    }
    
    // MARK: - bine
    override func bind() {
        super.bind()
        
        countdownSettingTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: CountdownSettingViewReactor) {
        // MARK: action
        rx.viewDidLoad
            .map { Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        countdownSettingTableView.rx.itemSelected
            .map { Reactor.Action.select($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .bind(to: countdownSettingTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedIndexPath }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.countdownSettingTableView.selectRow(at: $0, animated: true, scrollPosition: .none) })
            .disposed(by: disposeBag)
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - countdown setting datasource
typealias CountdownSettingSectionModel = SectionModel<Void, CountdownSettingMenu>

struct CountdownSettingMenu {
    let title: String
    let seconds: Int
    
    init(seconds: Int) {
        self.seconds = seconds
        title = String(format: "countdown_setting_second_title_format".localized, seconds)
    }
}
