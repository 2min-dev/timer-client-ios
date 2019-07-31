//
//  AlarmChangeView.swift
//  timer
//
//  Created by JSilver on 27/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class AlarmChangeView: UIView {
    // MARK: - view properties
    let backButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .yellow
        return view
    }()
    
    let currentAlarmLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        return view
    }()
    
    private lazy var headerStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [backButton, currentAlarmLabel])
        view.axis = .horizontal
        
        // Set constarint of subviews
        backButton.snp.makeConstraints { make in
            make.width.equalTo(backButton.snp.height)
        }
        
        return view
    }()
    
    let alarmTableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        
        // Register alarm cell
        view.register(AlarmChangeTableViewCell.self, forCellReuseIdentifier: AlarmChangeTableViewCell.ReuseableIdentifier)
        
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [headerStackView, alarmTableView])
        view.axis = .vertical
        
        // Set constarint of subviews
        headerStackView.snp.makeConstraints { make in
            make.height.equalTo(50.adjust())
        }
        
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        addAutolayoutSubview(contentStackView)
        // Set constarint of subviews
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
