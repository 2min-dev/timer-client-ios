//
//  NoticeListTableViewCell.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class NoticeListTableViewCell: UITableViewCell {
    // MARK: - view properties
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    let dateLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = R.Color.silver
        return view
    }()
    
    // MARK: - constructor
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = R.Color.clear
        selectionStyle = .none
        
        let divider = UIView()
        divider.backgroundColor = R.Color.silver
        
        // Set constraint of subviews
        addAutolayoutSubviews([titleLabel, dateLabel, divider])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30.2.adjust())
            make.trailing.equalTo(dateLabel.snp.leading).inset(-5.adjust())
            make.centerY.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.8.adjust())
            make.centerY.equalToSuperview()
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
