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
        // TODO: sample text. remove it
        view.additionalAttributedText = NSAttributedString(string: "setting_version_lastest_title".localized)
        return view
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.rowHeight = 60.adjust()
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        // Set constraint of subviews
        addAutolayoutSubviews([tableView, headerView])
        tableView.snp.makeConstraints({ make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        })
        
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
