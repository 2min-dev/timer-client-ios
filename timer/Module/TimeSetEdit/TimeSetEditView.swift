//
//  TimeSetEditView.swift
//  timer
//
//  Created by JSilver on 31/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimeSetEditView: UIView {
    // MARK: - view properties
    let headerView: Header = {
        let view = Header()
        return view
    }()
    
    let titleTextField: UITextField = {
        let view = UITextField()
        view.textAlignment = .center
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = Constants.Color.black
        // Disable auto correction (keyboard)
        view.autocorrectionType = .no
        return view
    }()
    
    let titleClearButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_clear"), for: .normal)
        view.isHidden = true
        return view
    }()
    
    let titleHintLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = Constants.Color.lightGray
        return view
    }()
    
    private let titleInputBottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.appColor
        return view
    }()
    
    private lazy var titleInputView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([titleHintLabel, titleClearButton, titleTextField, titleInputBottomLineView])
        titleTextField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.center.equalToSuperview()
            make.width.equalTo(128.adjust())
        }
        
        titleClearButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(titleClearButton.snp.height)
        }
        
        titleHintLabel.snp.makeConstraints { make in
            make.edges.equalTo(titleTextField)
        }
        
        titleInputBottomLineView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return view
    }()
    
    let sumOfTimersLabel: UILabel = {
        let view = UILabel()
        view.textColor = Constants.Color.lightGray
        return view
    }()
    
    let endOfTimerLabel: UILabel = {
        let view = UILabel()
        view.textColor = Constants.Color.lightGray
        return view
    }()
    
    private lazy var timeInfoView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([sumOfTimersLabel, endOfTimerLabel])
        sumOfTimersLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        endOfTimerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    private let timerOptionLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = Constants.Color.black.cgColor
        layer.lineWidth = 1
        return layer
    }()
    
    lazy var timerOptionView: UIView = {
        let view = UIView()
        view.layer.addSublayer(timerOptionLayer)
        view.backgroundColor = .white
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
        view.addAutolayoutSubviews([titleInputView, timeInfoView, timerOptionView, timerBadgeCollectionView])
        titleInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(200.adjust())
            make.height.equalTo(36.adjust())
        }
        
        timeInfoView.snp.makeConstraints { make in
            make.top.equalTo(titleInputView.snp.bottom).offset(10.adjust())
            make.centerX.equalTo(titleInputView)
            make.width.equalTo(titleInputView)
        }
        
        timerOptionView.snp.makeConstraints { make in
            make.top.equalTo(titleInputView.snp.bottom).offset(87.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(250.adjust())
            make.height.equalTo(271.adjust())
        }
        
        timerBadgeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(timerOptionView.snp.bottom).offset(8.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        return view
    }()
    
    let footerView: Footer = {
        let view = Footer()
        view.buttons = [
            FooterButton(title: "footer_button_cancel".localized, type: .normal),
            FooterButton(title: "footer_button_confirm".localized, type: .highlight)
        ]
        return view
    }()
    
    // MARK: - properties
    private var disposeBag = DisposeBag()
    
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
            make.bottom.equalToSuperview()
        }
        
        footerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update timer option layer frame
        timerOptionLayer.frame = CGRect(x: 0, y: 0, width: timerOptionView.bounds.width, height: timerOptionView.bounds.height)
        timerOptionLayer.path = drawTimerOptionLayer(frame: timerOptionView.bounds)
    }
    
    // MARK: - bind
    private func bind() {
        titleTextField.rx.textChanged
            .filter { $0 != nil }
            .map { !$0!.isEmpty }
            .bind(to: titleHintLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        titleTextField.rx.textChanged
            .filter { $0 != nil }
            .map { $0!.isEmpty }
            .bind(to: titleClearButton.rx.isHidden)
            .disposed(by: disposeBag)
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
