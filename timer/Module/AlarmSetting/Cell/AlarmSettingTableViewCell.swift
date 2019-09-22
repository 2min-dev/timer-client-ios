//
//  AlarmSettingTableViewCell.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class AlarmSettingTableViewCell: UITableViewCell {
    // MARK: - view properties
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private let playButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_play"), for: .normal)
        view.isHidden = true
        return view
    }()
    
    private let selectIconImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon_selected"))
        return view
    }()
    
    // MARK: - constructor
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Constants.Color.white
        selectionStyle = .none
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.silver
        
        // Set constraint of subviews
        addAutolayoutSubviews([playButton, titleLabel, selectIconImageView, divider])
        playButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.2.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(selectIconImageView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(playButton.snp.trailing).inset(-4.adjust())
            make.trailing.equalTo(selectIconImageView.snp.leading)
            make.centerY.equalToSuperview()
        }
        
        selectIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.8.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(selectIconImageView.snp.width)
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        selectIconImageView.isHidden = !selected
    }
}
