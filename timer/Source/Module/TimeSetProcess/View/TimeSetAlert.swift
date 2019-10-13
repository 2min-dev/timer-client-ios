//
//  TimeSetAlert.swift
//  timer
//
//  Created by JSilver on 28/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetAlert: UIView {
    // MARK: - view properties
    private let textLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(10.adjust())
        view.textColor = Constants.Color.codGray
        view.numberOfLines = 2
        return view
    }()
    
    let cancelButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_clear"), for: .normal)
        return view
    }()
    
    lazy var confirmButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_confirm_white"), for: .normal)
        return view
    }()
    
    private let containerLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = Constants.Color.white.cgColor
        layer.strokeColor = Constants.Color.codGray.cgColor
        layer.lineWidth = 1
        return layer
    }()
    
    private let confirmLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = Constants.Color.carnation.cgColor
        layer.strokeColor = Constants.Color.codGray.cgColor
        layer.lineWidth = 1
        return layer
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.addSublayer(containerLayer)
        view.layer.addSublayer(confirmLayer)
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([textLabel, cancelButton, confirmButton])
        textLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalTo(cancelButton.snp.leading).inset(-6.adjust())
            make.centerY.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(confirmButton.snp.leading).inset(-4.adjust())
            make.bottom.equalToSuperview()
            make.width.equalTo(36.adjust())
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(50.adjust())
        }
        
        return view
    }()
    
    // MARK: - properties
    let tailSize = CGSize(width: 12.adjust(), height: 8.adjust())
    let tailPosition = CGPoint(x: 19.adjust(), y: 54.adjust())
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 250.adjust(), height: 54.adjust())
    }
    
    var title: String? {
        set {
            guard let attributedString = textLabel.attributedText as? NSMutableAttributedString,
                let string = newValue else { return }
            
            attributedString.mutableString.setString(string)
            textLabel.attributedText = attributedString
        }
        get { return textLabel.attributedText?.string }
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
    
    convenience init(text: String) {
        self.init(frame: .zero)
        // Create paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8.adjust()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        // Set attributed string
        textLabel.attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func draw(_ rect: CGRect) {
        containerLayer.frame = containerView.bounds
        containerLayer.path = drawContrainerBorderLayer(frame: containerView.frame, corner: 5.adjust()).cgPath
        
        confirmLayer.frame = confirmButton.bounds
        confirmLayer.path = drawConfirmBorderLayer(frame: confirmButton.frame, corner: 5.adjust()).cgPath
    }
    
    // MARK: - private method
    /// Draw alert layer. (+ 0.5 pt is revision for prevent anti-aliasing of layer path)
    private func drawContrainerBorderLayer(frame: CGRect, corner radius: CGFloat) -> UIBezierPath {
        // Initial point of border path
        let initialPoint = CGPoint(x: radius, y: frame.height)
        // Tail points
        let tailPoints: [CGPoint] = [
            CGPoint(x: tailPosition.x - tailSize.width / 2, y: frame.height), // tail top-left
            CGPoint(x: tailPosition.x, y: tailPosition.y + tailSize.height), // tail bottom-center
            CGPoint(x: tailPosition.x + tailSize.width / 2, y: frame.height) // tail top-right
        ]
        // Round corner points
        let cornerPoints: [(CGPoint, CGPoint?, CGPoint?)] = [
            // Right-Bottom
            (CGPoint(x: frame.width - radius, y: frame.height), nil, nil),
            (CGPoint(x: frame.width, y: frame.height - radius),
             CGPoint(x: frame.width - radius * 0.5, y: frame.height),
             CGPoint(x: frame.width, y: frame.height - radius * 0.5)),
            // Right-Top
            (CGPoint(x: frame.width, y: radius), nil, nil),
            (CGPoint(x: frame.width - radius, y: 0),
             CGPoint(x: frame.width, y: radius * 0.5),
             CGPoint(x: frame.width - radius * 0.5, y: 0)),
            // Left-Top
            (CGPoint(x: radius, y: 0), nil, nil),
            (CGPoint(x: 0, y: radius),
             CGPoint(x: radius * 0.5, y: 0),
             CGPoint(x: 0, y: radius * 0.5)),
            // Left-Bottom
            (CGPoint(x: 0, y: frame.height - radius), nil, nil),
            (CGPoint(x: radius, y: frame.height),
             CGPoint(x: 0, y: frame.height - radius * 0.5),
             CGPoint(x: radius * 0.5, y: frame.height))
        ]
        
        // Draw path
        let path = UIBezierPath()
        path.move(to: initialPoint)
        
        tailPoints.forEach { path.addLine(to: $0) }
        cornerPoints.forEach {
            if let controlPoint1 = $0.1, let controlPoint2 = $0.2 {
                path.addCurve(to: $0.0, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            } else {
                path.addLine(to: $0.0)
            }
        }
        
        return path
    }
    
    private func drawConfirmBorderLayer(frame: CGRect, corner radius: CGFloat) -> UIBezierPath {
        // Initial point of border path
        let initialPoint = CGPoint(x: frame.origin.x, y: frame.height)
        // Round corner points
        let cornerPoints: [(CGPoint, CGPoint?, CGPoint?)] = [
            // Right-Bottom
            (CGPoint(x: frame.origin.x + frame.width - radius, y: frame.height), nil, nil),
            (CGPoint(x: frame.origin.x + frame.width, y: frame.height - radius),
             CGPoint(x: frame.origin.x + frame.width - radius * 0.5, y: frame.height),
             CGPoint(x: frame.origin.x + frame.width, y: frame.height - radius * 0.5)),
            // Right-Top
            (CGPoint(x: frame.origin.x + frame.width, y: radius), nil, nil),
            (CGPoint(x: frame.origin.x + frame.width - radius, y: 0),
             CGPoint(x: frame.origin.x + frame.width, y: radius * 0.5),
             CGPoint(x: frame.origin.x + frame.width - radius * 0.5, y: 0)),
            // Left-Top
            (CGPoint(x: frame.origin.x, y: 0), nil, nil),
            // Left-Bottom
            (initialPoint, nil, nil)
        ]
        
        // Draw path
        let path = UIBezierPath()
        path.move(to: initialPoint)
        
        cornerPoints.forEach {
            if let controlPoint1 = $0.1, let controlPoint2 = $0.2 {
                path.addCurve(to: $0.0, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            } else {
                path.addLine(to: $0.0)
            }
        }
        
        return path
    }
    
    deinit {
        Logger.verbose()
    }
}
