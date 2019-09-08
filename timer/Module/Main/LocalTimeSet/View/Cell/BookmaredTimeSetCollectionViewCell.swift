//
//  BookmaredTimeSetCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 06/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class BookmaredTimeSetCollectionViewCell: UICollectionViewCell {
    enum DividerType {
        case none
        case top
        case bottom
        case both
    }
    
    // MARK: - view properties
    private let timeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = Constants.Color.codGray
        // TODO: Sample text. remove it
        view.text = "HH:MM:SS"
        return view
    }()
    
    private let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
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
    
    private let topDivider: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.gallery
        return view
    }()
    
    private let bottomDivider: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.gallery
        return view
    }()
    
    // MARK: - properties
    var dividerType: DividerType = .none {
        didSet { setDividerType(dividerType) }
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubviews([topDivider, timeLabel, endOfTimeSetLabel, titleLabel, timerIconImageView, timerCountLabel, bottomDivider])
        topDivider.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20.adjust())
            make.leading.equalToSuperview().inset(10.adjust())
            make.trailing.equalTo(endOfTimeSetLabel.snp.leading).inset(-10.adjust())
        }
        
        endOfTimeSetLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10.adjust())
            make.centerY.equalTo(timeLabel)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10.adjust())
            make.trailing.equalTo(timerIconImageView.snp.leading)
            make.bottom.equalToSuperview().inset(20.adjust())
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.trailing.equalTo(timerCountLabel.snp.leading).offset(4.adjust())
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(36.adjust())
            make.height.equalTo(timerIconImageView.snp.width)
        }
        
        timerCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10.adjust())
            make.centerY.equalTo(titleLabel).offset(1)
        }
        
        bottomDivider.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private method
    private func initLayout() {
        backgroundColor = Constants.Color.white
    }
    
    // MARK: - private method
    private func setDividerType(_ type: DividerType) {
        topDivider.isHidden = true
        bottomDivider.isHidden = true
        
        switch type {
        case .top:
            topDivider.isHidden = false
            
        case .bottom:
            bottomDivider.isHidden = false
            
        case .both:
            topDivider.isHidden = false
            bottomDivider.isHidden = false
            
        default:
            break
        }
    }
}
