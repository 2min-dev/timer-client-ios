//
//  CommonLoading.swift
//  timer
//
//  Created by JSilver on 2019/10/16.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommonLoading: UIView {
    // MARK: - view properties
    private lazy var progressView: UIView = {
        let view = UIView()
        view.layer.addSublayer(circleLayer)
        return view
    }()
    
    private let circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = Constants.Color.carnation.cgColor
        layer.fillColor = Constants.Color.clear.cgColor
        layer.lineCap = .round
        layer.strokeStart = 0
        layer.strokeEnd = 0
        return layer
    }()
    
    // MARK: - properties
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 60.adjust(), height: 60.adjust())
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        
        // Set constraint of subviews
        addAutolayoutSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.edges.equalToSuperview().priority(.high)
            make.center.equalToSuperview().priority(.high)
            make.width.lessThanOrEqualTo(60.adjust())
            make.height.equalTo(progressView.snp.width)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func draw(_ rect: CGRect) {
        let lineWidth = progressView.bounds.width * 0.12
        circleLayer.lineWidth = lineWidth
        
        // Set layer frame consider of line width
        circleLayer.frame = progressView.bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        // Set path by created bezier path from inseted frame
        circleLayer.path = makeCircleBezirPath(frame: circleLayer.frame, lineWidth: lineWidth).cgPath
    }
    
    // MARK: - private method
    private func makeCircleBezirPath(frame: CGRect, lineWidth: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: CGPoint(x: frame.width * 0.5,
                                               y: frame.height * 0.5),
                            radius: frame.width * 0.5,
                            startAngle: -CGFloat.pi * 0.5,
                            endAngle: CGFloat.pi * 1.5,
                            clockwise: true)
    }
    
    // MARK: - public method
    /// Start loading animation
    func startLoading() {
        isHidden = false
        
        // Opacity (fade-in) animation
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.duration = 0.3
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = .forwards
        
        // End stroke animation
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = 0
        endAnimation.toValue = 1
        endAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.75, 0.75, 0, 1)
        
        // Start stroke animation
        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
        startAnimation.fromValue = 0
        startAnimation.toValue = 1
        startAnimation.beginTime = 0.3
        startAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.75, 0.75, 0, 1)
        
        // Group stroke animation
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [endAnimation, startAnimation]
        groupAnimation.duration = 1.4
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        
        CATransaction.begin()
        // Start animation
        layer.add(opacityAnimation, forKey: "fadeIn")
        circleLayer.add(groupAnimation, forKey: "opacity")
        CATransaction.commit()
    }
    
    /// Stop loading animation
    func stopLoading() {
        // Opacity (fade-out) animation
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.duration = 0.3
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = .forwards
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.isHidden = true
            // Remove all layer animation when animation completed
            self.circleLayer.removeAllAnimations()
        }
        // Start animation
        layer.add(opacityAnimation, forKey: "fadeOut")
        CATransaction.commit()
    }
}

extension Reactive where Base: CommonLoading {
    var isLoading: Binder<Bool> {
        return Binder(base) { loadingView, isLoading in
            isLoading ? loadingView.startLoading() : loadingView.stopLoading()
        }
    }
}
