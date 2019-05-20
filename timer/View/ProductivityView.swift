//
//  ProductivityView.swift
//  timerset-ios
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
    let timerLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(25.adjust())
        view.text = ""
        view.textAlignment = .center
        return view
    }()
    
    private let timerDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let timerInputLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(20.adjust())
        view.text = ""
        view.textAlignment = .center
        return view
    }()
    
    private lazy var timerStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.timerLabel, self.timerDividerView, self.timerInputLabel])
        view.axis = .vertical
        view.spacing = 10.adjust()
        return view
    }()
    
    let keyPadView: KeyPad = {
        let view = KeyPad()
        view.fontSize = 30.adjust()
        return view
    }()
    
    let hourButton: UIButton = {
        let view = UIButton()
        let string = "productivity_button_hour_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.ExtraBold.withSize(25.adjust())
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
            .font: Constants.Font.ExtraBold.withSize(25.adjust())
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
            .font: Constants.Font.ExtraBold.withSize(25.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    private lazy var timeStackView: UIStackView = { [unowned self] in
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
            .font: Constants.Font.ExtraBold.withSize(25.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    let addButton: UIButton = {
        let view = UIButton()
        let string = "productivity_button_timer_add_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.ExtraBold.withSize(40.adjust())
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
            .font: Constants.Font.ExtraBold.withSize(25.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
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
        view.setSubviewForAutoLayout(self.footerStackView)
        return view
    }()
    
    let sideTimerTableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.backgroundColor = Constants.Color.clear
        view.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        return view
    }()
    
    lazy var contentView: UIView = { [unowned self] in
        let view = UIView()
        view.setSubviewsForAutoLayout([self.timerStackView, self.keyPadView, self.timeStackView])
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        setSubviewsForAutoLayout([contentView, sideTimerTableView])
        
        // Content view
        contentView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.center.equalTo(safeAreaLayoutGuide)
            } else {
                make.center.equalToSuperview()
            }
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        // Timer view
        timerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        timerLabel.snp.makeConstraints { make in
            make.height.equalTo(30.adjust())
        }
        
        timerDividerView.snp.makeConstraints { make in
            make.height.equalTo(2.adjust())
        }
        
        timerInputLabel.snp.makeConstraints { make in
            make.height.equalTo(20.adjust())
        }
        
        // Key pad view
        keyPadView.snp.makeConstraints { make in
            make.top.equalTo(timerStackView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(320.adjust())
        }
        
        // Time button view (시, 분, 초)
        timeStackView.snp.makeConstraints { make in
            make.top.equalTo(keyPadView.snp.bottom).offset(10.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(30.adjust())
        }
        
        // Side timer table view
        sideTimerTableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(contentView.snp.trailing).inset(10.adjust())
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
