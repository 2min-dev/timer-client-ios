//
//  TimeSetPopup.swift
//  timer
//
//  Created by JSilver on 27/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetPopup: UIView {
    // MARK: - view properties
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.font = R.Font.bold.withSize(15.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    private let timerIconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = R.Icon.icTimer
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let view = UILabel()
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.font = R.Font.bold.withSize(10.adjust())
        view.textColor = R.Color.doveGray
        return view
    }()
    
    let confirmButton: UIButton = {
        let view = UIButton()
        view.setImage(R.Icon.icBtnConfirm, for: .normal)
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = R.Color.gallery
        view.layer.cornerRadius = 6.adjust()
        view.layer.shadow(alpha: 0.04, offset: CGSize(width: 0, height: 3.adjust()), blur: 6)
    
        let wrapView = UIView()
        // Set constraint of subviews
        wrapView.addAutolayoutSubviews([titleLabel, timerIconImageView, subtitleLabel])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15.adjust())
            make.centerY.equalToSuperview()
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(timerIconImageView.snp.width)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(timerIconImageView.snp.trailing).inset(5.adjust())
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([wrapView, confirmButton])
        wrapView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(confirmButton.snp.leading)
            make.bottom.equalToSuperview()
        }
        
        confirmButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(confirmButton.snp.width)
        }
        
        return view
    }()
    
    // MARK: - properties
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var subtitle: String? {
        get { return subtitleLabel.text }
        set {
            subtitleLabel.text = newValue
            
            subtitleLabel.isHidden = newValue?.isEmpty ?? true
            timerIconImageView.isHidden = newValue?.isEmpty ?? true
        }
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    convenience init(origin: CGPoint) {
        self.init(frame: CGRect(x: origin.x, y: origin.y, width: 330.adjust(), height: 60.adjust()))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public method
    func show(completeion: (() -> Void)? = nil) {
        guard let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        
        // Calculate destination position
        var frame = self.frame
        frame.origin.y -= frame.height + 14.adjust()
        if #available(iOS 11.0, *) {
            frame.origin.y -= keyWindow.safeAreaInsets.bottom
        }
        
        // Create animator
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.frame = frame
        }
        
        animator.addCompletion {
            if $0 == .end {
                completeion?()
            }
        }
        
        // Start show animation
        animator.startAnimation()
    }
    
    func dismiss(completeion: (() -> Void)? = nil) {
        guard let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        
        // Calculate destination position
        var frame = self.frame
        frame.origin.y = keyWindow.bounds.height
        
        // Create animator
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.frame = frame
        }
        
        animator.addCompletion {
            if $0 == .end {
                self.removeFromSuperview()
                completeion?()
            }
        }
        
        // Start dismiss animation
        animator.startAnimation()
    }
}
