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

class AlarmSettingViewController: BaseViewController, View {
    // MARK: - view properties
    private var alarmSettingView: AlarmSettingView { return view as! AlarmSettingView }
    
    private var headerView: CommonHeader { return alarmSettingView.headerView }
    
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
        alarmSettingTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: AlarmSettingViewReactor) {
        // MARK: action
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.headerActionHandler(type: $0) })
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
    
    deinit {
        Logger.verbose()
    }
}

extension AlarmSettingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetThreshold: CGFloat = 3
        let blurThreshold: CGFloat = 10
        let weight: CGFloat = 5
        
        // Set shadow by scroll
        headerView.layer.shadow(alpha: 0.04,
                                offset: CGSize(width: 0, height: min(scrollView.contentOffset.y / weight, offsetThreshold)),
                                blur: min(scrollView.contentOffset.y / weight, blurThreshold))
    }
}

// MARK: - alarm setting datasource
typealias AlarmSettingSectionModel = SectionModel<Void, AlarmSettingMenu>

struct AlarmSettingMenu {
    let title: String
    
    init(title: String) {
        self.title = title
    }
}
