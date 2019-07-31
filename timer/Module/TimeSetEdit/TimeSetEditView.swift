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
        return view
    }()
    
    private let titleHintLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = Constants.Color.lightGray
        // TODO: Layout test title. remove it.
        view.text = "1번째 생산성"
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
        view.addAutolayoutSubviews([titleHintLabel, titleTextField, titleInputBottomLineView])
        titleTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleHintLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.lightGray
        // TODO: Layout test title. remove it.
        view.text = "전체 00:01:00"
        return view
    }()
    
    let endOfTimerLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.lightGray
        // TODO: Layout test title. remove it.
        view.text = "종료 9:42 AM"
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
    
    let startAfterSaveCheckBox: CheckBox = {
        let view = CheckBox()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.lightGray
        view.highlightedTextColor = Constants.Color.black
        // TODO: Layout test title. remove it.
        view.text = "저장 완료 후 시작"
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
        view.addAutolayoutSubviews([titleInputView, timeInfoView, startAfterSaveCheckBox, timerOptionView, timerBadgeCollectionView])
        titleInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(200.adjust())
            make.height.equalTo(50.adjust())
        }
        
        timeInfoView.snp.makeConstraints { make in
            make.top.equalTo(titleInputView.snp.bottom).offset(10.adjust())
            make.centerX.equalTo(titleInputView)
            make.width.equalTo(titleInputView).offset(-14.adjust())
        }
        
        startAfterSaveCheckBox.snp.makeConstraints { make in
            make.top.equalTo(timeInfoView.snp.bottom).offset(36.5.adjust())
            make.centerX.equalToSuperview()
        }
        
        timerOptionView.snp.makeConstraints { make in
            make.top.equalTo(startAfterSaveCheckBox.snp.bottom).offset(28.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(250.adjust())
            make.height.equalTo(271.adjust())
        }
        
        timerBadgeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(timerOptionView.snp.bottom).offset(14.5.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        return view
    }()
    
    let footerView: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = "Footer View"
        label.textAlignment = .center
        label.backgroundColor = .lightGray
        label.layer.borderWidth = 1
        
        view.addAutolayoutSubview(label)
        label.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
            make.height.equalTo(70.adjust())
        }
        
        view.backgroundColor = .gray
        view.layer.borderWidth = 1
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
        titleTextField.rx.text
            .map { !$0!.isEmpty }
            .bind(to: titleHintLabel.rx.isHidden)
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
