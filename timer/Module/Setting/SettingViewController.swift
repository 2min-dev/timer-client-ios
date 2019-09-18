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
    // MARK: - view properties
    private var settingView: SettingView { return view as! SettingView }
    
    private var headerView: CommonHeader { return settingView.headerView }
    
    private var settingTableView: UITableView { return settingView.tableView }
    
    // MARK: - properties
    var coordinator: SettingViewCoordinator
    
    private let dataSource = RxTableViewSectionedReloadDataSource<SettingSectionModel>(configureCell: { (datasource, tableview, indexPath, item) in
        let cell = tableview.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = item.title
        return cell
    })
    
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
    }
    
    // MARK: - bind
    func bind(reactor: SettingViewReactor) {
        // MARK: action
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.headerActionHandler(type: $0) })
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .map { $0.sections }
            .bind(to: settingTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - action
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

// MARK: - setting datasource
typealias SettingSectionModel = SectionModel<Void, SettingItem>

struct SettingItem {
    var title: String
    var subTitle: String?
}
