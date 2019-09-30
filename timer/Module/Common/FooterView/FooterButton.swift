//
//  FooterButton.swift
//  timer
//
//  Created by JSilver on 04/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class FooterButton: UIButton {
    enum FooterButtonType {
        case normal
        case sub
        case highlight
        
        var textColor: UIColor {
            switch self {
            case .normal:
                return Constants.Color.codGray
                
            case .sub:
                return Constants.Color.carnation
                
            case .highlight:
                return Constants.Color.white
            }
        }
        
        var backgroundLayer: CALayer {
            switch self {
            case .normal,
                 .sub:
                let backgroundLayer = CALayer()
                backgroundLayer.backgroundColor = Constants.Color.gallery.cgColor
                return backgroundLayer
                
            case .highlight:
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [Constants.Color.carnation.cgColor, Constants.Color.darkBlue.cgColor]
                return gradientLayer
            }
        }
    }
    
    // MARK: - view properties
    private var backgroundLayer: CALayer
    
    // MARK: - properties
    var type: FooterButtonType
    var title: String?

    override var isEnabled: Bool {
        didSet {
            backgroundLayer.removeFromSuperlayer()
            if isEnabled {
                backgroundLayer = type.backgroundLayer
            } else {
                backgroundLayer = FooterButtonType.normal.backgroundLayer
            }
        }
    }
    
    // MARK: - constructor
    init(title: String?, type: FooterButtonType) {
        self.type = type
        self.title = title
        self.backgroundLayer = type.backgroundLayer
        
        super.init(frame: .zero)
        
        layer.insertSublayer(backgroundLayer, at: 0)
        
        setTitle(title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func draw(_ rect: CGRect) {
        layer.shadow(alpha: 0.04, offset: CGSize(width: 0, height: 6.adjust()), blur: 6)
        
        backgroundLayer.frame = bounds
        backgroundLayer.cornerRadius = bounds.height * 0.12
        
        if let gradientLayer = backgroundLayer as? CAGradientLayer {
            // Resize gradient layer to square
            let edge = max(bounds.width, bounds.height)
            gradientLayer.bounds.size = CGSize(width: edge, height: edge)
            
            // Calculate gradient points from bounds
            let startYPosition: CGFloat = 0.5 - (bounds.height / gradientLayer.bounds.height) * 0.5
            let endYPosition: CGFloat = 0.5 + (bounds.height / gradientLayer.bounds.height) * 0.5 
            
            gradientLayer.startPoint = CGPoint(x: 0.5, y: startYPosition)
            gradientLayer.endPoint = CGPoint(x: 1.5, y: endYPosition)
            
            // Create gradient mask layer
            let maskLayer = CALayer()
            maskLayer.frame = bounds
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.cornerRadius = bounds.height * 0.12
            maskLayer.frame.origin.y = (gradientLayer.bounds.height - bounds.height) / 2
            // Set mask layer
            gradientLayer.mask = maskLayer
        }
    }
    
    // MARK: - private method
    private func setTitle(_ title: String?) {
        titleLabel?.font = Constants.Font.ExtraBold.withSize(15.adjust())
        
        setTitleColor(type.textColor, for: .normal)
        setTitleColor(Constants.Color.silver, for: .disabled)
        
        setTitle(title, for: .normal)
    }
}
