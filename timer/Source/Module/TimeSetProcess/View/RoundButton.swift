//
//  RoundButton.swift
//  timer
//
//  Created by JSilver on 06/10/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RoundButton: UIView {
    // MARK: - constants
    private let MINIMUM_WIDTH = 40.adjust()
    
    // MARK: - view properties
    private let imageButton: UIButton = {
        let view = UIButton()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [imageButton, titleLabel])
        view.axis = .horizontal
        view.spacing = -2.adjust()
        return view
    }()
    
    // MARK: - properties
    var title: String? {
        get { titleLabel.text }
        set {
            titleLabel.isHidden = newValue == nil
            titleLabel.text = newValue
            
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
    var font: UIFont {
        get { titleLabel.font }
        set {
            titleLabel.font = newValue
            invalidateIntrinsicContentSize()
        }
    }
    var textColor: UIColor {
        get { titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }
    var isSelected: Bool = false {
        didSet {
            imageButton.isSelected = isSelected
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: calcWidthFromButton(imageButton, with: titleLabel), height: 40.adjust())
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubview(buttonStackView)
        
        // Add tap gesture
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        addGestureRecognizer(tapGesture)
        
        layer.cornerRadius = 20.adjust()
    }
    
    convenience init(title: String? = nil, image: UIImage? = nil) {
        self.init(frame: .zero)
        
        self.title = title
        setImage(image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageButton.currentImage == nil || titleLabel.text == nil {
            // Set view align .center when one element exist only
            buttonStackView.snp.remakeConstraints { make in
                make.center.equalToSuperview()
            }
        } else {
            buttonStackView.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }
    }
    
    // MARK: - private method
    /// Calculate button width from button and label
    private func calcWidthFromButton(_ button: UIButton, with label: UILabel) -> CGFloat {
        let imageWidth = button.currentImage == nil ? 0 : button.sizeThatFits(.zero).width
        let titleWidth = label.text == nil ? 0 : label.sizeThatFits(.zero).width
        
        var width = imageWidth + titleWidth
        if imageWidth > 0 && titleWidth > 0 {
            // Adjust width by view constraints
            width -= 2.adjust()
        }
        
        if width > MINIMUM_WIDTH {
            // Add padding if width greater than minimum width
            width += 17.adjust()
        } else {
            width = MINIMUM_WIDTH
        }
        
        return width
    }
    
    // MARK: - public method
    func setImage(_ image: UIImage?, for state: UIControl.State = .normal) {
        imageButton.isHidden = image == nil
        imageButton.setImage(image, for: state)
        
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - selector
    @objc fileprivate func tapHandler(gesture: UITapGestureRecognizer) {
        
    }
}

extension Reactive where Base: RoundButton {
    var tap: ControlEvent<Void> {
        return ControlEvent(events: methodInvoked(#selector(base.tapHandler(gesture:))).map { _ in Void() })
    }
    
    var isSelected: Binder<Bool> {
        return Binder(base) { view, isSelected in
            view.isSelected = isSelected
        }
    }
}
