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
    
    // MARK: properties
    var coordinator: SettingViewCoordinator!
    
    // MARK: ### lifecycle ###
    override func loadView() {
        self.view = SettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: ### reactor bind ###
    func bind(reactor: SettingViewReactor) {
        // MARK: action
        
        // MARK: state
    }
}
