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
        view.setImage(UIImage(named: "btn_back"), for: .normal)
        return view
    }()
    
    let currentAlarmLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.gallery
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([backButton, currentAlarmLabel, divider])
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(7.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(24.adjust())
            make.height.equalTo(backButton.snp.width)
        }
        
        currentAlarmLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(13.adjust())
            make.trailing.equalToSuperview().inset(13.adjust())
            make.centerY.equalToSuperview()
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
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
        let view = UIStackView(arrangedSubviews: [headerView, alarmTableView])
        view.axis = .vertical
        
        // Set constraint of subviews
        headerView.snp.makeConstraints { make in
            make.height.equalTo(52.adjust())
        }
        
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        // Set constraint of subviews
        addAutolayoutSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
