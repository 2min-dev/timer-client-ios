//
//  SettingViewController.swift
//  timerset-ios
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
        case develop
    }
    
    // MARK: view properties
    private var settingView: SettingView { return self.view as! SettingView }
    private var settingTableView: UITableView { return settingView.tableView }
    
    // MARK: properties
    var coordinator: SettingViewCoordinator!
    
    private var sections: [BaseTableSection] = []
    
    // MARK: lifecycle
    override func loadView() {
        self.view = SettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize menu list
        initMenus()
        
        settingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        initSettingTableView()
    }
    
    deinit {
        Logger.verbose("")
    }
    
    // MARK: reactor bind
    func bind(reactor: SettingViewReactor) {
        // MARK: action
        
        // MARK: state
        
    }
    
    // MARK: initalize methods
    
    /**
     * initialize menu items
     */
    private func initMenus() {
        var setting: [BaseTableItem] = []
        setting.append(BaseTableItem(title: "앱 정보"))
        
        var develop: [BaseTableItem] = []
        develop.append(BaseTableItem(title: "실험실"))
        
        sections.append(BaseTableSection(title: "설정", items: setting))
        sections.append(BaseTableSection(title: "개발자 옵션", items: develop))
    }
    
    /**
     * initizlize setting table view datasource & delegate
     */
    private func initSettingTableView() {
        // set setting menu table view datasource
        let dataSource = RxTableViewSectionedReloadDataSource<BaseTableSection>(configureCell: { (datasource, tableview, indexPath, item) in
            let cell = tableview.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            cell.textLabel?.text = item.title
            return cell
        })
        
        //        set section header
        //        dataSource.titleForHeaderInSection = { dataSource, index in
        //            return dataSource.sectionModels[index].title
        //        }
        
        Observable.just(sections)
            .bind(to: settingTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
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
                        self.coordinator.present(for: .appInfo)
                    default:
                        Logger.error("not valid index path.")
                    }
                // develop menu
                case .develop:
                    switch indexPath.row {
                    case 0:
                        self.coordinator.present(for: .laboratory)
                    default:
                        Logger.error("not valid index path.")
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
