//
//  SavedTimeSetHighlightCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 06/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class SavedTimeSetHighlightCollectionViewCell: UICollectionViewCell {
    // MARK: - view properties
    private let timeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(24.adjust())
        view.textColor = Constants.Color.white
        // TODO: Sample text. remove it
        view.text = "HH:MM:SS"
        return view
    }()
    
    private let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.gallery
        // TODO: Sample text. remove it
        view.text = "HH:MM:SS"
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.white
        // TODO: Sample text. remove it
        view.text = "타임셋 명"
        return view
    }()
    
    private let timerIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_timer_white")
        return view
    }()
    
    private let timerCountLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.gallery
        // TODO: Sample text. remove it
        view.text = "N"
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubviews([timeLabel, endOfTimeSetLabel, titleLabel, timerIconImageView, timerCountLabel])
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30.adjust())
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalTo(endOfTimeSetLabel.snp.leading).inset(-10.adjust())
        }
        
        endOfTimeSetLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.adjust())
            make.centerY.equalTo(timeLabel)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalTo(timerIconImageView.snp.leading)
            make.bottom.equalToSuperview().inset(30.adjust())
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.trailing.equalTo(timerCountLabel.snp.leading).offset(4.adjust())
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(36.adjust())
            make.height.equalTo(timerIconImageView.snp.width)
        }
        
        timerCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.adjust())
            make.centerY.equalTo(titleLabel).offset(1)
        }
        
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private method
    private func initLayout() {
        backgroundColor = Constants.Color.carnation
        layer.shadow(alpha: 0.04, offset: CGSize(width: 0, height: 3.adjust()), blur: 4)
        layer.cornerRadius = 20.adjust()
    }
}
