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
        view.additionalButtons = [.bookmark]
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(24.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let allTimeTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "time_set_all_time_title".localized
        return view
    }()
    
    let allTimeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var allTimeStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [allTimeTitleLabel, allTimeLabel])
        view.axis = .horizontal
        view.spacing = 20.adjust()
        
        // Set constraint of subviews
        allTimeTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(60.adjust())
        }
        
        return view
    }()
    
    let endOfTimeSetTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "time_set_end_time_title".localized
        return view
    }()
    
    let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var endOfTimeSetStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [endOfTimeSetTitleLabel, endOfTimeSetLabel])
        view.axis = .horizontal
        view.spacing = 20.adjust()
        
        // Set constraint of subviews
        endOfTimeSetTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(60.adjust())
        }
        
        return view
    }()
    
    let alarmTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "timer_alarm_title".localized
        return view
    }()
    
    let alarmLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var alarmStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [alarmTitleLabel, alarmLabel])
        view.axis = .horizontal
        view.spacing = 20.adjust()
        
        // Set constraint of subviews
        alarmTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(60.adjust())
        }
        
        return view
    }()
    
    let commentTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "timer_comment_title".localized
        return view
    }()
    
    let commentTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = Constants.Color.clear
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.isEditable = false
        view.isSelectable = false
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
    
        // Set line height of text view
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7.adjust()
        
        view.typingAttributes = [.foregroundColor: Constants.Color.doveGray,
                                 .paragraphStyle: paragraphStyle]
        return view
    }()
    
    private lazy var commentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [commentTitleLabel, commentTextView])
        view.axis = .horizontal
        view.alignment = .top
        view.spacing = 20.adjust()
        
        // Set constraint of subviews
        commentTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(60.adjust())
        }
        
        commentTextView.snp.makeConstraints { make in
            make.height.equalTo(56.adjust())
        }
        
        return view
    }()
    
    private lazy var infoStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [allTimeStackView, endOfTimeSetStackView, alarmStackView, commentStackView])
        view.axis = .vertical
        view.spacing = 10.adjust()
        return view
    }()
    
    let timerBadgeCollectionView: TimerBadgeCollectionView = {
        let view = TimerBadgeCollectionView(frame: .zero)
        if let layout = view.collectionViewLayout as? TimerBadgeCollectionViewFlowLayout {
            layout.axisPoint = CGPoint(x: 60.adjust(), y: 0)
            layout.axisAlign = .left
        }
        return view
    }()
    
    private let alarmIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_sound")
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([titleLabel, infoStackView, timerBadgeCollectionView])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(35.adjust())
            make.leading.equalToSuperview().inset(60.adjust())
            make.trailing.equalToSuperview().inset(20.adjust()).priorityHigh()
        }

        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(173.adjust())
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
        }

        timerBadgeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(23.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        return view
    }()
    
    let editButton: FooterButton = {
        return FooterButton(title: "footer_button_edit".localized, type: .sub)
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
        backgroundColor = Constants.Color.alabaster
        
        addAutolayoutSubviews([headerView, contentView, footerView])
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top).priorityHigh()
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
