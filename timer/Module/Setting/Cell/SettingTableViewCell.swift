//
//  SettingTableViewCell.swift
//  timer
//
//  Created by JSilver on 18/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    // MARK: - view properties
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let subtitleLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private let arrowIconImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon_arrow_right"))
        return view
    }()
    
    // MARK: - constructor
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.silver
        
        // Set constraint of subviews
        addAutolayoutSubviews([titleLabel, subtitleLabel, arrowIconImageView, divider])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30.2.adjust())
            make.trailing.equalTo(subtitleLabel.snp.leading)
            make.centerY.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.trailing.equalTo(arrowIconImageView.snp.leading).inset(-4.2.adjust())
            make.centerY.equalToSuperview()
        }
        
        arrowIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.8.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(arrowIconImageView.snp.width)
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.8.adjust())
            make.trailing.equalToSuperview().inset(20.8.adjust())
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
