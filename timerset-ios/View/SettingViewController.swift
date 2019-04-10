//
//  SettingViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class SettingViewController: BaseViewController, View {
    // MARK: view properties
    private unowned var settingView: SettingView { return self.view as! SettingView }
    private unowned var settingTableView: UITableView { return settingView.tableView }
    
    // MARK: properties
    var coordinator: SettingViewCoordinator!
    
    // MARK: ### lifecycle ###
    override func loadView() {
        self.view = SettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTableView.delegate = self
        settingTableView.dataSource = self
    }
    
    // MARK: ### reactor bind ###
    func bind(reactor: SettingViewReactor) {
        // MARK: action
        
        // MARK: state
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "추가 기능"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
        cell.textLabel?.text = "실험실"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(UIStoryboard(name: "laboratory", bundle: nil).instantiateViewController(withIdentifier: "PageViewController"), animated: true)
    }
}
