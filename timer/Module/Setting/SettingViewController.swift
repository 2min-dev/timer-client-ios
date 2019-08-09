//
//  SettingViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxDataSources
import ReactorKit

class SettingViewController: BaseViewController, View {
    enum SettingSection: Int {
        case setting = 0
    }
    
    // MARK: - view properties
    private var settingView: SettingView { return view as! SettingView }
    private var settingTableView: UITableView { return settingView.tableView }
    
    // MARK: - properties
    var coordinator: SettingViewCoordinator
    
    // MARK: - constructor
    init(coordinator: SettingViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = SettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        initSettingTableView()
    }
    
    deinit {
        Logger.verbose()
    }
    
    // MARK: - bind
    func bind(reactor: SettingViewReactor) {
        // MARK: action
        reactor.action.onNext(.viewDidLoad)
        
        // MARK: state
        reactor.state
            .map { $0.sections }
            .bind(to: settingTableView.rx.items(dataSource: RxTableViewSectionedReloadDataSource<CommonTableSection>(configureCell: { (datasource, tableview, indexPath, item) in
                let cell = tableview.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
                cell.textLabel?.text = item.title
                return cell
            })))
            .disposed(by: disposeBag)
    }
    
    /**
     * initizlize setting table view datasource & delegate
     */
    private func initSettingTableView() {
        // set setting menu select action
        settingTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                // caution: ControlEvent doesn't complete. so you have to add [weak self]
                // when you want to use .subscribe about ControlEvent (ex. tap)
                guard let `self` = self else { return }
                
                guard let cell = self.settingTableView.cellForRow(at: indexPath) else {
                    Logger.error("setting table view doesn't have cell at indexPath.")
                    return
                }
                
                guard let section: SettingSection = SettingSection(rawValue: indexPath.section) else {
                    Logger.error("setting table view doesn't have section at indexPath")
                    return
                }
                
                // set cell selected property to false for disable select background
                cell.isSelected = false
                
                switch section {
                // setting menu
                case .setting:
                    switch indexPath.row {
                    case 0:
                        _ = self.coordinator.present(for: .appInfo)
                    default:
                        Logger.error("not valid index path.")
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
