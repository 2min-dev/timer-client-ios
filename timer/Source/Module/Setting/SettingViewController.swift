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

class SettingViewController: BaseHeaderViewController, View {
    // MARK: - view properties
    private var settingView: SettingView { return view as! SettingView }
    
    override var headerView: CommonHeader { return settingView.headerView }
    
    private var settingTableView: UITableView { return settingView.settingTableView }
    
    // MARK: - properties
    var coordinator: SettingViewCoordinator
    
    private let dataSource = RxTableViewSectionedReloadDataSource<SettingSectionModel>(configureCell: { (datasource, tableView, indexPath, item) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.name, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        
        cell.titleLabel.text = item.title
        cell.subtitleLabel.text = item.subtitle
        
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
        // Register cell
        settingTableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.name)
    }
    
    // MARK: - bind
    override func bind() {
        super.bind()
        settingTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: SettingViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .flatMap { Observable.merge(
                .just(Reactor.Action.loadMenu),
                .just(Reactor.Action.versionCheck)
            )}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        settingTableView.rx.itemSelected
            .do(onNext: { [weak self] in self?.settingTableView.deselectRow(at: $0, animated: true) })
            .withLatestFrom(reactor.state.map { $0.sections }, resultSelector: { $1[$0.section].items[$0.row] })
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: $0.route) })
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .compactMap { $0.isLatestVersion }
            .distinctUntilChanged()
            .map { $0 ?
                NSAttributedString(string: "setting_version_latest_title".localized) :
                NSAttributedString(string: "setting_version_need_update_title".localized) }
            .bind(to: headerView.rx.additionalText)
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .bind(to: settingTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - action
    /// Handle header button tap action according to button type
    override func handleHeaderAction(_ action: Header.Action) {
        super.handleHeaderAction(action)
        
        switch action {
        case .additional:
            guard let isLatestVersion = reactor?.currentState.isLatestVersion else { return }
            if !isLatestVersion {
                openAppStore()
            }
            
        default:
            break
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - setting datasource
typealias SettingSectionModel = SectionModel<Void, SettingMenu>

enum SettingMenu {
    case notice
    case alarm(String)
    case countdown(Int)
    case teamInfo
    case license
    
    var title: String {
        switch self {
        case .notice:
            return "notice_title".localized
            
        case .alarm:
            return "alarm_setting_title".localized
            
        case .countdown:
            return "countdown_setting_title".localized
            
        case .teamInfo:
            return "team_info_title".localized
            
        case .license:
            return "opensource_license_title".localized
        }
    }
    
    var subtitle: String? {
        switch self {
        case let .alarm(name):
            return String(format: "setting_alarm_setting_subtitle_format".localized, name)
            
        case let .countdown(seconds):
            return String(format: "setting_countdown_setting_subtitle_format".localized, seconds)
            
        default:
            return nil
        }
    }
    
    var route: SettingViewCoordinator.Route {
        switch self {
        case .notice:
            return .noticeList

        case .alarm(_):
            return .alarmSetting
            
        case .countdown(_):
            return .countdownSetting
            
        case .teamInfo:
            return .teamInfo

        case .license:
            return .license
        }
    }
}
