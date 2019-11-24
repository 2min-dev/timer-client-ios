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
        view.additionalButtons = [.history, .setting]
        view.backButton.isHidden = true
        return view
    }()
    
    let timerInputView: TimerInputView = {
        let view = TimerInputView()
        return view
    }()
    
    let allTimeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        view.textAlignment = .center
        return view
    }()
    
    let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        view.textAlignment = .center
        return view
    }()
    
    lazy var timeInfoView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [allTimeLabel, endOfTimeSetLabel])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.setHidden(true)
        
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
        view.font = Constants.Font.Regular.withSize(24.adjust())
        view.cancelButton.titleLabel?.font = Constants.Font.Regular.withSize(18.adjust())
        view.foregroundColor = Constants.Color.codGray
        view.cancelButton.setHidden(true)
        
        // Set key touch animation
        view.keys.forEach { $0.addTarget(self, action: #selector(touchKey(sender:)), for: .touchUpInside) }
        return view
    }()
    
    let timeKeyPadView: TimeKeyPad = {
        let view = TimeKeyPad()
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.setTitleColor(normal: Constants.Color.codGray, disabled: Constants.Color.silver)
        view.setHidden(true)
        
        // Set key touch animation
        view.keys.forEach { $0.addTarget(self, action: #selector(touchKey(sender:)), for: .touchUpInside) }
        return view
    }()
    
    let timerBadgeCollectionView: TimerBadgeCollectionView = {
        let view = TimerBadgeCollectionView(frame: .zero)
        view.setContentHuggingPriority(.required, for: .vertical)
        
        view.isEditable = true
        view.isAxisFixed = true
        if let layout = view.collectionViewLayout as? TimerBadgeCollectionViewFlowLayout {
            layout.axisPoint = TimerBadgeCollectionViewFlowLayout.Axis.center
            layout.axisAlign = .center
        }
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        let timerContentView: UIView = UIView()
        timerContentView.addAutolayoutSubviews([keyPadView, timeKeyPadView, timerBadgeCollectionView])
        keyPadView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(330.adjust())
            make.height.equalTo(260.adjust())
        }
        
        timeKeyPadView.snp.makeConstraints { make in
            make.top.equalTo(keyPadView.snp.bottom).inset(2.5.adjust())
            make.leading.equalTo(keyPadView)
            make.trailing.equalTo(keyPadView)
            make.height.equalTo(60.adjust())
        }
        
        timerBadgeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(timeKeyPadView.snp.bottom).offset(5.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let guideView: UIView = UIView()
        guideView.addAutolayoutSubview(timerContentView)
        timerContentView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([timerInputView, timeInfoView, timeInputLabel, dimedView, guideView])
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
            make.top.equalTo(timerInputView.snp.bottom).offset(12.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(timerInputView.snp.width)
        }
        
        dimedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        guideView.snp.makeConstraints { make in
            make.top.equalTo(timerInputView.snp.bottom).offset(6.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    let timerOptionView: TimerOptionView = {
        return TimerOptionView()
    }()
    
    let saveButton: FooterButton = {
        return FooterButton(title: "footer_button_save".localized, type: .sub)
    }()
    
    let startButton: FooterButton = {
        return FooterButton(title: "footer_button_start".localized, type: .highlight)
    }()
    
    lazy var footerView: Footer = {
        let view = Footer()
        view.buttons = [saveButton, startButton]
        return view
    }()
    
    let dimedView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.alabaster
        view.alpha = 0
        return view
    }()
    
    // MARK: - properties
    var isEnabled: Bool = true {
        didSet {
            showDimedView(isShow: !isEnabled, animated: true)
        }
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        addAutolayoutSubviews([headerView, contentView, timerOptionView])
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide).priorityHigh()
            } else {
                make.bottom.equalToSuperview().priorityHigh()
            }
        }
        
        timerOptionView.snp.makeConstraints { make in
            make.bottom.equalTo(timerBadgeCollectionView.snp.top).inset(-17.adjust())
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private method
    private func showDimedView(isShow: Bool, animated: Bool) {
        if animated {
            dimedView.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                self.dimedView.alpha = isShow ? 0.8 : 0
            }, completion: { _ in
                self.dimedView.isHidden = !isShow
            })
        } else {
            dimedView.alpha = isShow ? 0.8 : 0
            dimedView.isHidden = !isShow
        }
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

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ProductivityPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> ProductivityView {
        return ProductivityView()
    }
    
    func updateUIView(_ uiView: ProductivityView, context: Context) {
        // Nothing
    }
}

struct Previews_ProductivityView: PreviewProvider {
    static var previews: some View {
        Group {
            ProductivityPreview()
                .previewDevice("iPhone 6s")
            
            ProductivityPreview()
                .previewDevice("iPhone 11")
        }
    }
}

#endif
