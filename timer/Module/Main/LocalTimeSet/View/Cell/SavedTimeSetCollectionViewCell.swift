//
//  SavedTimeSetCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 06/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class SavedTimeSetCollectionViewCell: UICollectionViewCell {
    // MARK: - view properties
    private let timeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(24.adjust())
        view.textColor = Constants.Color.codGray
        // TODO: Sample text. remove it
        view.text = "HH:MM:SS"
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        // TODO: Sample text. remove it
        view.text = "타임셋 명"
        return view
    }()
    
    private let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        // TODO: Sample text. remove it
        view.text = "HH:MM:SS"
        return view
    }()
    
    private let timerIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_timer")
        return view
    }()
    
    private let timerCountLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        // TODO: Sample text. remove it
        view.text = "N"
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubviews([timeLabel, titleLabel, endOfTimeSetLabel, timerIconImageView, timerCountLabel])
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20.adjust())
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).inset(-20.adjust())
            make.leading.equalTo(timeLabel)
            make.trailing.equalTo(timeLabel)
        }
        
        endOfTimeSetLabel.snp.makeConstraints { make in
            make.leading.equalTo(timeLabel)
            make.trailing.equalTo(timerIconImageView.snp.leading)
            make.bottom.equalToSuperview().inset(20.adjust())
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.trailing.equalTo(timerCountLabel.snp.leading).offset(4.adjust())
            make.centerY.equalTo(endOfTimeSetLabel)
            make.width.equalTo(36.adjust())
            make.height.equalTo(timerIconImageView.snp.width)
        }
        
        timerCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(timeLabel)
            make.centerY.equalTo(endOfTimeSetLabel).offset(1)
        }
        
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private method
    private func initLayout() {
        backgroundColor = Constants.Color.white
        layer.shadow(alpha: 0.04, offset: CGSize(width: 0, height: 3.adjust()), blur: 4)
        layer.borderColor = Constants.Color.gallery.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 20.adjust()
    }
}
