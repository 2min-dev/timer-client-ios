//
//  ProductivityView.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProductivityView: UIView {
    enum TimeKey {
        case hour
        case minute
        case second
    }
    
    enum TimerButtonType {
        case save
        case add
        case start
    }
    
    // MARK: - view properties
    let headerView: Header = {
        let view = Header()
        return view
    }()
    
    let timerLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.text = "0"
        view.textAlignment = .center
        return view
    }()
    
    let timerClearButton: UIButton = {
        let view = UIButton()
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.Regular.withSize(15.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: "X", attributes: attributes), for: .normal)
        view.isHidden = true
        return view
    }()
    
    lazy var timerInputView: UIView = { [unowned self] in
        let view = UIView()
        view.layer.borderWidth = 1.adjust()
        view.layer.borderColor = Constants.Color.gray.cgColor
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([self.timerLabel, self.timerClearButton])
        self.timerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(11.adjust())
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-11.adjust())
            make.width.equalTo(140.adjust())
        }
        
        self.timerClearButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(timerLabel.snp.trailing)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    let sumOfTimersLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.lightGray
        return view
    }()
    
    let endOfTimerLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.lightGray
        return view
    }()
    
    let timerInputLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.lightGray
        view.textAlignment = .center
        return view
    }()
    
    private lazy var timerInfoStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.sumOfTimersLabel, self.endOfTimerLabel, self.timerInputLabel])
        view.axis = .vertical
        view.spacing = 5.adjust()
        
        // Set constarint of subviews
        timerInputLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(13.adjust())
        }
        return view
    }()
    
    let keyPadView: KeyPad = {
        let view = KeyPad()
        view.font = Constants.Font.ExtraBold
        view.fontSize = 30.adjust()
        
        view.cancelButton.isHidden = true
        return view
    }()
    
    let hourButton: UIButton = {
        let view = UIButton()
        let string = "productivity_button_hour_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.ExtraBold.withSize(20.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    let minuteButton: UIButton = {
        let view = UIButton()
        let string = "productivity_button_minute_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.ExtraBold.withSize(20.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    let secondButton: UIButton = {
        let view = UIButton()
        let string = "productivity_button_second_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.ExtraBold.withSize(20.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    private lazy var timeButtonStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.hourButton, self.minuteButton, self.secondButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    let saveButton: UIButton = {
        let view = UIButton()
        let string = "productivity_button_timer_save_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.ExtraBold.withSize(20.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        
        view.contentHorizontalAlignment = .left
        return view
    }()
    
    let addButton: UIButton = {
        let view = UIButton()
        let string = "productivity_button_timer_add_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.ExtraBold.withSize(20.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    let startButton: UIButton = {
        let view = UIButton()
        let string = "productivity_button_timer_start_title".localized
        
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.ExtraBold.withSize(20.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        
        view.contentHorizontalAlignment = .right
        return view
    }()
    
    lazy var footerStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.saveButton, self.addButton, self.startButton])
        view.backgroundColor = Constants.Color.white
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    lazy var footerView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = Constants.Color.white
        
        // Set constraint of subviews
        view.addAutolayoutSubview(self.footerStackView)
        footerStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(208.adjust())
        }
        
        return view
    }()
    
    let timerBadgeCollectionView: TimerBadgeCollectionView = {
        let view = TimerBadgeCollectionView(frame: .zero)
        return view
    }()
    
    lazy var contentView: UIView = { [unowned self] in
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([self.timerInputView, self.timerInfoStackView, self.keyPadView, self.timeButtonStackView, self.timerBadgeCollectionView])
        timerInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(43.5.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(200.adjust())
        }
        
        timerInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(timerInputView.snp.bottom).offset(20.adjust())
            make.centerX.equalToSuperview()
        }
        
        keyPadView.snp.makeConstraints { make in
            make.top.equalTo(timerInputView.snp.bottom).offset(84.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(258.adjust())
            make.height.equalTo(232.adjust())
        }
        
        timeButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(keyPadView.snp.bottom).offset(10.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(258.adjust())
        }
        
        timerBadgeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(timeButtonStackView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        addAutolayoutSubviews([headerView, contentView])
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
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - extension
extension Reactive where Base: ProductivityView {
    var timeKeyTap: ControlEvent<Base.TimeKey> {
        let hourObservable = base.hourButton.rx.tap.map { Base.TimeKey.hour }
        let minuteObservable = base.minuteButton.rx.tap.map { Base.TimeKey.minute }
        let secondObservable = base.secondButton.rx.tap.map { Base.TimeKey.second }
        
        let source = Observable.merge(hourObservable, minuteObservable, secondObservable)
        return ControlEvent(events: source)
    }
}
