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
    
    private var settingTableView: UITableView { return settingView.settingTableView }
    
    // MARK: - properties
    var coordinator: SettingViewCoordinator
    
    private let dataSource = RxTableViewSectionedReloadDataSource<SettingSectionModel>(configureCell: { (datasource, tableview, indexPath, item) in
        guard let cell = tableview.dequeueReusableCell(withIdentifier: SettingTableViewCell.name, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        
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
        
        settingTableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.name)
    }
    
    // MARK: - bind
    override func bind() {
        settingTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: SettingViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.headerActionHandler(type: $0) })
            .disposed(by: disposeBag)
        
        settingTableView.rx.itemSelected
            .do(onNext: { [weak self] in self?.settingTableView.deselectRow(at: $0, animated: true) })
            .withLatestFrom(reactor.state.map { $0.sections }, resultSelector: { $1[$0.section].items[$0.row] })
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: $0.route) })
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .filter { $0.shouldSectionReload }
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
    
    /// Handle setting menu selected
    private func menuSelectd(indexPath: IndexPath) {
        
    }
    
    deinit {
        Logger.verbose()
    }
}

extension SettingViewController: UIScrollViewDelegate {
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
