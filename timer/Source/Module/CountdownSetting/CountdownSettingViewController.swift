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

class CountdownSettingViewController: BaseHeaderViewController, ViewControllable, View {
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
    
    // MARK: - bine
    override func bind() {
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
        
        countdownSettingTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: CountdownSettingViewReactor) {
        // MARK: action
        rx.viewDidLoad
            .map { .load }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        countdownSettingTableView.rx.itemSelected
            .do(onNext: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .map { .select($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .map { $0.sections }
            .distinctUntilChanged()
            .map { $0.value }
            .bind(to: countdownSettingTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedIndex }
            .distinctUntilChanged()
            .map { IndexPath(item: $0, section: 0) }
            .subscribe(onNext: { [weak self] in self?.countdownSettingTableView.selectRow(at: $0, animated: true, scrollPosition: .none) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    /// Handle header button tap action according to button type
    func handleHeaderAction(_ action: Header.Action) {
        switch action {
        case .back:
            coordinator.present(for: .dismiss, animated: true)
            
        default:
            break
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

struct CountdownSettingMenu {
    let title: String
    let seconds: Int
    
    init(seconds: Int) {
        self.seconds = seconds
        title = String(format: "countdown_setting_second_title_format".localized, seconds)
    }
}
