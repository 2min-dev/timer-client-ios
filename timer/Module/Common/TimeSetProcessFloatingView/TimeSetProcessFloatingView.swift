//
//  TimeSetProcessFloatingView.swift
//  timer
//
//  Created by JSilver on 02/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class TimeSetProcessFloatingView: UIView, View {
    // MARK: - view properties
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(10.adjust())
        view.textColor = Constants.Color.codGray
        // TODO: sample text, remove it
        view.text = "타임셋 명"
        return view
    }()
    
    private let timeLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = Constants.Color.codGray
        // TODO: sample text, remove it
        view.text = "00:00:00"
        return view
    }()
    
    private let timerIconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = UIImage(named: "icon_timer")
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let view = UILabel()
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.font = Constants.Font.Bold.withSize(10.adjust())
        view.textColor = Constants.Color.doveGray
        // TODO: sample text, remove it
        view.text = "N/M (P회 반복)"
        return view
    }()
    
    private let playButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_play"), for: .normal)
        view.setImage(UIImage(named: "btn_pause"), for: .selected)
        return view
    }()
    
    private let closeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_clear"), for: .normal)
        return view
    }()
    
    // MARK: - properties
    var disposeBag = DisposeBag()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 55.adjust())
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.gallery
        
        addAutolayoutSubviews([titleLabel, timeLabel, timerIconImageView, subtitleLabel, playButton, closeButton])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10.adjust())
            make.leading.equalToSuperview().inset(40.adjust())
            make.trailing.equalTo(playButton.snp.leading).inset(-10.adjust())
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5.adjust())
            make.leading.equalTo(titleLabel)
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.leading.equalTo(timeLabel.snp.trailing).offset(5.adjust())
            make.centerY.equalTo(timeLabel)
            make.width.equalTo(36.adjust())
            make.height.equalTo(closeButton.snp.width)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(timerIconImageView.snp.trailing).inset(5.adjust())
            make.trailing.equalTo(playButton.snp.leading).inset(-10.adjust())
            make.centerY.equalTo(timeLabel)
        }
        
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(closeButton.snp.width)
        }
        
        playButton.snp.makeConstraints { make in
            make.trailing.equalTo(closeButton.snp.leading).inset(-10.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(closeButton.snp.width)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    func bind(reactor: TimeSetProcessFloatingViewReactor) {
        // MARK: action
        
        // MARK: state
    }
}
