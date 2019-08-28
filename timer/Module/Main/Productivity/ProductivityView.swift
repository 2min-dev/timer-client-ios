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
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.buttonTypes = [.search, .history, .setting]
        view.isBackButtonHidden = true
        return view
    }()
    
    let timerInputView: TimerInputView = {
        let view = TimerInputView()
        return view
    }()
    
    let allTimeLabel: UILabel = {
        let view = UILabel()
        view.textColor = Constants.Color.silver
        view.textAlignment = .center
        return view
    }()
    
    let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.textColor = Constants.Color.silver
        view.textAlignment = .center
        return view
    }()
    
    lazy var timeInfoView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [allTimeLabel, endOfTimeSetLabel])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.isHidden = true
        return view
    }()
    
    let timeInputLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        view.textAlignment = .center
        return view
    }()
    
    let keyPadView: NumberKeyPad = {
        let view = NumberKeyPad()
        view.font = Constants.Font.Regular.withSize(30.adjust())
        view.foregroundColor = Constants.Color.codGray
        view.cancelButton.isHidden = true
        
        // Set key touch animation
        view.keys.forEach {
            $0.addTarget(self, action: #selector(touchKey(sender:)), for: .touchUpInside)
        }
        return view
    }()
    
    let timeKeyView: TimeKeyView = {
        let view = TimeKeyView()
        view.font = Constants.Font.ExtraBold.withSize(20.adjust())
        view.setTitleColor(normal: Constants.Color.codGray, disabled: Constants.Color.silver)
        
        // Set key touch animation
        view.keys.forEach {
            $0.addTarget(self, action: #selector(touchKey(sender:)), for: .touchUpInside)
        }
        return view
    }()
    
    let timerBadgeCollectionView: TimerBadgeCollectionView = {
        let view = TimerBadgeCollectionView(frame: .zero)
        view.isAxisFixedPoint = true
        view.layout?.axisPoint = TimerBadgeCollectionViewFlowLayout.Axis.center
        view.layout?.axisAlign = .center
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([timerInputView, timeInfoView, timeInputLabel, keyPadView, timeKeyView, timerBadgeCollectionView])
        timerInputView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(215.adjust())
            make.height.equalTo(50.adjust())
        }
        
        timeInfoView.snp.makeConstraints { make in
            make.top.equalTo(timerInputView.snp.bottom).offset(12.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(timerInputView.snp.width)
        }
        
        timeInputLabel.snp.makeConstraints { make in
            make.edges.equalTo(timeInfoView)
        }
        
        keyPadView.snp.makeConstraints { make in
            make.top.equalTo(timerInputView.snp.bottom).offset(30.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(270.adjust())
            make.height.equalTo(280.adjust())
        }
        
        timeKeyView.snp.makeConstraints { make in
            make.top.equalTo(keyPadView.snp.bottom)
            make.leading.equalTo(keyPadView)
            make.trailing.equalTo(keyPadView)
            make.height.equalTo(70.adjust())
        }
        
        timerBadgeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(timeKeyView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        return view
    }()

    private let timerOptionLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = Constants.Color.white.cgColor
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
    
    let saveButton: FooterButton = {
        return FooterButton(title: "footer_button_save".localized, type: .normal)
    }()
    
    let startButton: FooterButton = {
        return FooterButton(title: "footer_button_start".localized, type: .highlight)
    }()
    
    lazy var footerView: Footer = {
        let view = Footer()
        view.buttons = [
            saveButton,
            startButton
        ]
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
            make.bottom.equalTo(timerBadgeCollectionView.snp.top).offset(-8.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(250.adjust())
            make.height.equalTo(271.adjust())
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
        
    }
    
    override func draw(_ rect: CGRect) {
        timerOptionLayer.path = drawTimerOptionLayer(frame: timerOptionView.frame).cgPath
    }
    
    // MARK: - private method
    private func drawTimerOptionLayer(frame: CGRect) -> UIBezierPath {
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
        // Draw path
        edgePoints.forEach { path.addLine(to: $0) }
        
        return path
    }
    
    // MARK: - selector
    /// Animate key pad dumping when touched
    @objc private func touchKey(sender: UIButton) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1, 1.2, 1]
        animation.keyTimes = [0, 0.5, 1.0]
        animation.duration = 0.2

        sender.layer.add(animation, forKey: "touch")
    }
}
