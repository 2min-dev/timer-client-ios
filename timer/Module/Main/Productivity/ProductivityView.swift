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
    // MARK: - constants
    enum TimerButtonType {
        case save
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
        view.textAlignment = .center
        return view
    }()
    
    let timerClearButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_clear"), for: .normal)
        view.isHidden = true
        return view
    }()
    
    lazy var timerInputView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.adjust()
        view.layer.borderColor = Constants.Color.silver.cgColor
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([timerLabel, timerClearButton])
        self.timerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.timerClearButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(30.adjust())
        }
        
        return view
    }()
    
    let sumOfTimersLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.silver
        return view
    }()
    
    let endOfTimerLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.silver
        return view
    }()
    
    let loopButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_repeat_off"), for: .normal)
        view.setImage(UIImage(named: "btn_repeat_on"), for: .selected)
        return view
    }()
    
    lazy var timeInfoView: UIView = {
        let view = UIView()
        
        // Create info container view
        let infoContainerView = UIView()
        // Set constraint of subviews
        infoContainerView.addAutolayoutSubviews([sumOfTimersLabel, endOfTimerLabel])
        sumOfTimersLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        endOfTimerLabel.snp.makeConstraints { make in
            make.top.equalTo(sumOfTimersLabel.snp.bottom).offset(5.adjust())
            make.leading.equalTo(sumOfTimersLabel)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([infoContainerView, loopButton])
        infoContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        loopButton.snp.makeConstraints { make in
            make.centerY.equalTo(sumOfTimersLabel)
            make.leading.equalToSuperview().offset(6.75.adjust())
        }
        
        return view
    }()
    
    let timeInputLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(24.adjust())
        view.textColor = Constants.Color.silver
        view.textAlignment = .center
        view.isUserInteractionEnabled = false
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
            .foregroundColor: Constants.Color.codGray,
            .font: Constants.Font.ExtraBold.withSize(20.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.silver
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        
        attributes[.foregroundColor] = Constants.Color.silver
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .disabled)
        return view
    }()
    
    let minuteButton: UIButton = {
        let view = UIButton()
        let string = "productivity_button_minute_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.codGray,
            .font: Constants.Font.ExtraBold.withSize(20.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.silver
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        
        attributes[.foregroundColor] = Constants.Color.silver
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .disabled)
        return view
    }()
    
    let secondButton: UIButton = {
        let view = UIButton()
        let string = "productivity_button_second_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.codGray,
            .font: Constants.Font.ExtraBold.withSize(20.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.silver
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        
        attributes[.foregroundColor] = Constants.Color.silver
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .disabled)
        return view
    }()
    
    lazy var timeButtonStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [hourButton, minuteButton, secondButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.isHidden = true
        return view
    }()
    
    let saveButton: UIButton = {
        let view = UIButton()
        view.contentVerticalAlignment = .top
        
        let string = "productivity_button_timer_save_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.codGray,
            .font: Constants.Font.ExtraBold.withSize(20.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.silver
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        
        return view
    }()
    
    let startButton: UIButton = {
        let view = UIButton()
        view.contentVerticalAlignment = .top
        
        let string = "productivity_button_timer_start_title".localized
        
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.codGray,
            .font: Constants.Font.ExtraBold.withSize(20.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.silver
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        
        return view
    }()
    
    let timerBadgeCollectionView: TimerBadgeCollectionView = {
        let view = TimerBadgeCollectionView(frame: .zero)
        view.isAxisFixedPoint = true
        view.anchorPoint = TimerBadgeCollectionView.centerAnchor
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([timerInputView, timeInfoView, timeInputLabel, keyPadView, timeButtonStackView, timerBadgeCollectionView])
        timerInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(43.5.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(200.adjust())
            make.height.equalTo(40.adjust())
        }
        
        timeInfoView.snp.makeConstraints { make in
            make.top.equalTo(timerInputView.snp.bottom).offset(10.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(timerInputView.snp.width)
            make.height.equalTo(48.adjust())
        }
        
        timeInputLabel.snp.makeConstraints { make in
            make.edges.equalTo(timeInfoView)
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

    private let timerOptionLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = Constants.Color.codGray.cgColor
        layer.lineWidth = 1
        return layer
    }()
    
    lazy var timerOptionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.addSublayer(timerOptionLayer)
        view.isHidden = true
        return view
    }()
    
    private lazy var footerStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [saveButton, startButton])
        view.backgroundColor = Constants.Color.white
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    lazy var footerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.white
        
        // Set constraint of subviews
        view.addAutolayoutSubview(footerStackView)
        footerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(320.adjust())
        }
        
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        addAutolayoutSubviews([headerView, contentView, timerOptionView])
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
        
        timerOptionView.snp.makeConstraints { make in
            make.width.equalTo(250.adjust())
            make.height.equalTo(271.adjust())
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update timer option layer frame
        timerOptionLayer.frame = CGRect(x: 0, y: 0, width: timerOptionView.bounds.width, height: timerOptionView.bounds.height)
        timerOptionLayer.path = drawTimerOptionLayer(frame: timerOptionView.frame)
    }
    
    // MARK: - private method
    private func drawTimerOptionLayer(frame: CGRect) -> CGPath {
        let tailSize = CGSize(width: 13.adjust(), height: 8.adjust())
        
        let edgePoints: [CGPoint] = [
            CGPoint(x: -0.5, y: frame.height + 0.5),
            CGPoint(x: (frame.width - tailSize.width) * 0.5, y: frame.height + 0.5),
            CGPoint(x: frame.width * 0.5, y: frame.height + tailSize.height + 0.5),
            CGPoint(x: (frame.width + tailSize.width) * 0.5, y: frame.height + 0.5),
            CGPoint(x: frame.width + 0.5, y: frame.height + 0.5),
            CGPoint(x: frame.width + 0.5, y: -0.5),
            CGPoint(x: -0.5, y: -0.5)
        ]
        
        // Move starting point
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -0.5, y: -0.5))
        edgePoints.forEach {
            path.addLine(to: $0)
            path.move(to: $0)
        }
        
        return path.cgPath
    }
}

// MARK: - extension
extension Reactive where Base: ProductivityView {
    var timeKeyTap: ControlEvent<ProductivityViewReactor.Time> {
        let hourObservable = base.hourButton.rx.tap.map { ProductivityViewReactor.Time.hour }
        let minuteObservable = base.minuteButton.rx.tap.map { ProductivityViewReactor.Time.minute }
        let secondObservable = base.secondButton.rx.tap.map { ProductivityViewReactor.Time.second }
        
        let source = Observable.merge(hourObservable, minuteObservable, secondObservable)
        return ControlEvent(events: source)
    }
}
