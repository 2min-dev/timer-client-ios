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
    private let checkBoxLayer: CALayer = {
        let layer = CALayer()
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
        return layer
    }()
    
    private let checkedLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 1
        return layer
    }()
    
    private lazy var checkBoxView: UIView = {
        let view = UIView()
        view.layer.addSublayer(checkBoxLayer)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([checkBoxView, titleLabel])
        checkBoxView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(titleLabel.snp.height)
            make.width.equalTo(checkBoxView.snp.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkBoxView.snp.trailing).offset(space)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        return view
    }()
    
    // MARK: - properties
    var space: CGFloat = 10
    var text: String? {
        get { return titleLabel.text }
        set {
            titleLabel.text = newValue
            invalidateIntrinsicContentSize()
        }
    }
    var textColor: UIColor {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }
    var highlightedTextColor: UIColor? {
        get { return titleLabel.highlightedTextColor }
        set { titleLabel.highlightedTextColor = newValue }
    }
    var font: UIFont {
        get { return titleLabel.font }
        set {
            titleLabel.font = newValue
            invalidateIntrinsicContentSize()
        }
    }
    var isChecked: Bool = false {
        didSet {
            guard oldValue != isChecked else { return }
            checked(isChecked)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let textSize = titleLabel.sizeThatFits(.zero)
        return CGSize(width: textSize.height + textSize.width + space, height: textSize.height)
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addAutolayoutSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        initGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update check box layer frame
        checkBoxLayer.frame = CGRect(x: 0, y: 0, width: bounds.height, height: bounds.height)
        // Update checked layer frame & path
        checkedLayer.frame = checkBoxLayer.frame
        checkedLayer.path = drawCheckPath(frame: checkBoxLayer.frame)
    }
    
    // MARK: - private method
    private func initGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(gesture:)))
        addGestureRecognizer(tapGesture)
    }
    
    private func drawCheckPath(frame: CGRect) -> CGPath {
        let checkPoints: [CGPoint] = [
            CGPoint(x: frame.width * 0.42, y: frame.height * 0.75),
            CGPoint(x: frame.width * 0.83, y: frame.height * 0.33)
        ]
        
        // Move starting point
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width * 0.17, y: frame.height * 0.5))
        checkPoints.forEach {
            path.addLine(to: $0)
            path.move(to: $0)
        }
        
        return path.cgPath
    }
    
    private func checked(_ isChecked: Bool) {
        // Highlight title label
        titleLabel.isHighlighted = isChecked
        
        // Update check box layer
        if isChecked {
            checkBoxView.layer.addSublayer(checkedLayer)
        } else {
            checkedLayer.removeFromSuperlayer()
        }
    }
    
    // Leave for layer animation example
    private func animateCheck() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.2
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        checkBoxView.layer.addSublayer(checkedLayer)
        
        CATransaction.begin()
        checkedLayer.add(animation, forKey: "check")
        CATransaction.commit()
    }
    
    private func animateUncheck() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 0.2
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.checkedLayer.removeFromSuperlayer()
        }
        checkedLayer.add(animation, forKey: "uncheck")
        CATransaction.commit()
    }
    
    // MARK: - selctor
    @objc fileprivate func tapGestureHandler(gesture: UITapGestureRecognizer) {
        isChecked.toggle()
    }
}

// MARK: - extension
extension Reactive where Base: CheckBox {
    var tap: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(base.tapGestureHandler)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var isChecked: Binder<Bool> {
        return Binder(self.base) { checkBox, isChecked in
            checkBox.isChecked = isChecked
        }
    }
}
