//
//  SettingView.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class SettingView: UIView {
    // MARK: view propeties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.title = "setting_title".localized
        return view
    }()
    
    let settingTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = Constants.Color.clear
        view.separatorStyle = .none
        view.rowHeight = 60.adjust()
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        // Set constraint of subviews
        addAutolayoutSubviews([settingTableView, headerView])
        settingTableView.snp.makeConstraints({ make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview().priorityHigh()
            }
        })
        
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
