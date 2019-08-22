//
//  TimeSetDetailView.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetDetailView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.buttonTypes = [.share, .bookmark, .home]
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(24.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private let allTimeTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "time_set_all_time_full_title".localized
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let allTimeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private let endOfTimeSetTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "time_set_end_time_full_title".localized
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let repeatButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_repeat_off"), for: .normal)
        view.setImage(UIImage(named: "btn_repeat_on"), for: .selected)
        return view
    }()
    
    let plus1MinButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_plus_1min_disable"), for: .disabled)
        view.isEnabled = false
        return view
    }()
    
    private lazy var timeSetInfoView: UIView = {
        let view = UIView()
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.codGray
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([allTimeTitleLabel, allTimeLabel, endOfTimeSetTitleLabel, endOfTimeSetLabel, plus1MinButton, repeatButton, divider])
        allTimeTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(11.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalTo(endOfTimeSetTitleLabel)
        }
        
        allTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(allTimeTitleLabel)
            make.leading.equalTo(allTimeTitleLabel.snp.trailing).offset(10.adjust())
            make.bottom.equalTo(allTimeTitleLabel)
        }
        
        endOfTimeSetTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(allTimeTitleLabel.snp.bottom).offset(10.adjust())
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(16.adjust())
        }
        
        endOfTimeSetLabel.snp.makeConstraints { make in
            make.top.equalTo(endOfTimeSetTitleLabel)
            make.leading.equalTo(endOfTimeSetTitleLabel.snp.trailing).offset(10.adjust())
            make.bottom.equalTo(endOfTimeSetTitleLabel)
        }
        
        plus1MinButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(10.adjust())
            make.width.equalTo(36.adjust())
            make.height.equalTo(plus1MinButton.snp.width)
        }

        repeatButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(plus1MinButton.snp.leading).offset(-10.adjust())
            make.width.equalTo(36.adjust())
            make.height.equalTo(plus1MinButton.snp.width)
        }

        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return view
    }()
    
    let timerBadgeCollectionView: TimerBadgeCollectionView = {
        let view = TimerBadgeCollectionView()
        view.layout?.axisPoint = CGPoint(x: 60.adjust(), y: 0)
        view.layout?.axisAlign = .left
        return view
    }()
    
    private let alarmIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_sound")
        return view
    }()
    
    let alarmLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private lazy var alarmView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([alarmIconImageView, alarmLabel])
        alarmIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(alarmIconImageView.snp.width)
        }
        
        alarmLabel.snp.makeConstraints { make in
            make.leading.equalTo(alarmIconImageView.snp.trailing).offset(5.adjust())
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        return view
    }()
    
    private let commentIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_comment")
        return view
    }()
    
    let commentTextView: UITextView = {
        let view = UITextView()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        // Remove padding
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.isEditable = false
        return view
    }()
    
    private lazy var commentView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([commentIconImageView, commentTextView])
        commentIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(commentIconImageView.snp.width)
        }
        
        commentTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(11.33.adjust())
            make.leading.equalTo(commentIconImageView.snp.trailing).offset(5.adjust())
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([titleLabel, timeSetInfoView, timerBadgeCollectionView, alarmView, commentView])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(35.adjust())
            make.leading.equalToSuperview().inset(60.adjust())
            make.trailing.equalToSuperview().inset(10.adjust())
        }

        timeSetInfoView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(247.adjust())
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview()
        }

        timerBadgeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(timeSetInfoView.snp.bottom).offset(8.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        alarmView.snp.makeConstraints { make in
            make.top.equalTo(timerBadgeCollectionView.snp.bottom).offset(14.adjust())
            make.leading.equalToSuperview().inset(50.adjust())
            make.trailing.equalToSuperview().inset(10.adjust())
        }

        commentView.snp.makeConstraints { make in
            make.top.equalTo(alarmView.snp.bottom).inset(9.adjust())
            make.leading.equalToSuperview().inset(50.adjust())
            make.trailing.equalToSuperview().inset(10.adjust())
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    let editButton: FooterButton = {
        return FooterButton(title: "footer_button_edit".localized, type: .normal)
    }()
    
    let startButton: FooterButton = {
        return FooterButton(title: "footer_button_start".localized, type: .highlight)
    }()
    
    private lazy var footerView: Footer = {
        let view = Footer()
        view.buttons = [editButton, startButton]
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        addAutolayoutSubviews([headerView, contentView, footerView])
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top).offset(-10.adjust())
        }
        
        footerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
