//
//  CheckBox.swift
//  timer
//
//  Created by JSilver on 06/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CheckBox: UIView {
    // MARK: - view properties
    private lazy var checkBoxView: UIView = { [unowned self] in
        let view = UIView()
        view.layer.addSublayer(self.backgroundBoxLayer)
        return view
    }()
    
    private let backgroundBoxLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = Constants.Color.clear.cgColor
        layer.strokeColor = Constants.Color.black.cgColor
        layer.lineWidth = 2
        return layer
    }()
    
    private let checkedBoxLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = Constants.Color.black.cgColor
        return layer
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var containerView: UIView = { [unowned self] in
        let view = UIView()
        view.addSubview(self.checkBoxView)
        view.addSubview(self.titleLabel)
        return view
    }()
    
    // MARK: - properties
    var space: CGFloat = 10
    var isChecked: Bool = false {
        didSet {
            isChecked ? addOnAnimation() : addOffAnimation()
            // Reload check box layer
            setNeedsDisplay()
            layoutIfNeeded()
        }
    }
    override var intrinsicContentSize: CGSize {
        let textSize = titleLabel.intrinsicContentSize
        return CGSize(width: textSize.height + textSize.width + space, height: textSize.height + 10)
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        initGesture()
        
        setSubviewForAutoLayout(containerView)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkBoxView.snp.trailing).offset(space)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        checkBoxView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(titleLabel.snp.height)
            make.width.equalTo(checkBoxView.snp.height)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        containerView.snp.remakeConstraints { make in
            let textSize = titleLabel.intrinsicContentSize
            let size = CGSize(width: textSize.height + textSize.width + space, height: textSize.height)
            
            make.center.equalToSuperview()
            make.width.equalTo(size.width)
            make.height.equalTo(size.height)
        }
    }
    
    override func draw(_ rect: CGRect) {
        var path = UIBezierPath(arcCenter: CGPoint(x: checkBoxView.bounds.midX, y: checkBoxView.bounds.midY),
                                radius: checkBoxView.bounds.width / 2,
                                startAngle: -CGFloat.pi / 2,
                                endAngle: CGFloat.pi * 1.5,
                                clockwise: true)
        
        backgroundBoxLayer.path = path.cgPath
        
        path = UIBezierPath(arcCenter: CGPoint(x: checkBoxView.bounds.midX, y: checkBoxView.bounds.midY),
                            radius: checkBoxView.bounds.width / 2 - 3,
                            startAngle: -CGFloat.pi / 2,
                            endAngle: CGFloat.pi * 1.5,
                            clockwise: true)
        
        checkedBoxLayer.path = path.cgPath
    }
    
    // MARK: - private method
    private func initGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    private func addOnAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.2
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        checkBoxView.layer.addSublayer(checkedBoxLayer)
        checkedBoxLayer.frame = checkBoxView.bounds
        
        CATransaction.begin()
        checkedBoxLayer.add(animation, forKey: "on")
        CATransaction.commit()
    }
    
    private func addOffAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 0.2
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            guard let `self` = self else { return }
            self.checkedBoxLayer.removeFromSuperlayer()
        }
        checkedBoxLayer.add(animation, forKey: "off")
        CATransaction.commit()
    }
    
    // MARK: - public method
    func setAttributedTitle(_ title: NSAttributedString?) {
        titleLabel.attributedText = title
    }
    
    // MARK: - selctor
    @objc fileprivate func tapGesture(_ recognizer: UITapGestureRecognizer) {
        isChecked = !isChecked
    }
}

// MARK: - extension
extension Reactive where Base: CheckBox {
    var tap: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(base.tapGesture(_:))).map { _ in }
        return ControlEvent(events: source)
    }
    
    var isChecked: Binder<Bool> {
        return Binder(self.base) { checkBox, isChecked in
            checkBox.isChecked = isChecked
        }
    }
}
