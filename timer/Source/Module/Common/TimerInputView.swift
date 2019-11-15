//
//  TimerInputView.swift
//  timer
//
//  Created by JSilver on 05/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimerInputView: UIView {
    // MARK: - view properties
    let timerLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(24.adjust())
        view.textColor = Constants.Color.codGray
        view.textAlignment = .center
        return view
    }()
    
    let timerClearButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_clear_mini"), for: .normal)
        view.isHidden = true
        return view
    }()
    
    // MARK: - properties
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 215.adjust(), height: 50.adjust())
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubviews([timerLabel, timerClearButton])
        timerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        timerClearButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5.adjust())
            make.centerY.equalToSuperview()
            make.height.equalTo(36.adjust())
            make.width.equalTo(timerClearButton.snp.height)
        }
        
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        layer.cornerRadius = bounds.height / 2
    }
    
    // MARK: - private method
    private func initLayout() {
        backgroundColor = Constants.Color.white
        
        layer.borderWidth = 1.adjust()
        layer.borderColor = Constants.Color.gallery.cgColor
    }
    
    /// Animate to layer's border highlight
    fileprivate func borderHighlight(_ isHighlight: Bool) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.toValue = isHighlight ? Constants.Color.carnation.cgColor : Constants.Color.gallery.cgColor
        animation.duration = 0.3
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        // Set border color to `toValue`
        CATransaction.setCompletionBlock {
            self.layer.borderColor = isHighlight ? Constants.Color.carnation.cgColor : Constants.Color.gallery.cgColor
        }
        CATransaction.begin()
        layer.add(animation, forKey: "highlight")
        CATransaction.commit()
    }
}

extension Reactive where Base: TimerInputView {
    var timer: Binder<TimeInterval> {
        return Binder(base.self) { _, timeInterval in
            // Set timer clear button visible
            self.base.timerClearButton.isHidden = !(timeInterval > 0)
            
            // Set timer label
            let time = getTime(interval: timeInterval)
            self.base.timerLabel.text = String(format: "%02d:%02d:%02d", time.0, time.1, time.2)
            
            // Set view border
            self.base.borderHighlight(timeInterval > 0)
        }
    }
}
