//
//  CountdownSettingView.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class CountdownSettingView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.title = "countdown_setting_title".localized
        return view
    }()
    
    let countdownTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = R.Color.clear
        view.separatorStyle = .none
        view.rowHeight = 60.adjust()
        
        // Register cell
        view.register(CountdownSettingTableViewCell.self, forCellReuseIdentifier: CountdownSettingTableViewCell.name)
        
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = R.Color.alabaster
        
        // Set constraint of subviews
        addAutolayoutSubviews([countdownTableView, headerView])
        countdownTableView.snp.makeConstraints({ make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview().priority(.high)
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
