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
    
    let confirmButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = Constants.Color.carnation
        view.layer.borderColor = Constants.Color.codGray.cgColor
        view.layer.borderWidth = 1
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
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.addSublayer(containerLayer)
        
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
        get { textLabel.attributedText?.string }
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
        containerLayer.path = drawAlertLayer(frame: containerView.frame).cgPath
    }
    
    // MARK: - private method
    /// Draw alert layer. (+ 0.5 pt is revision for prevent anti-aliasing of layer path)
    private func drawAlertLayer(frame: CGRect) -> UIBezierPath {
        let edgePoints: [CGPoint] = [
            CGPoint(x: 0.5, y: frame.height - 0.5), // bottom-left
            CGPoint(x: tailPosition.x - tailSize.width / 2, y: frame.height - 0.5), // tail top-left
            CGPoint(x: tailPosition.x, y: tailPosition.y + tailSize.height - 0.5), // tail bottom-center
            CGPoint(x: tailPosition.x + tailSize.width / 2, y: frame.height - 0.5), // tail top-right
            CGPoint(x: frame.width, y: frame.height - 0.5), // bottom-right
            CGPoint(x: frame.width, y: 0.5), // top-right
            CGPoint(x: 0.5, y: 0.5) // top-left
        ]
        
        // Move starting point
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.5, y: 0.5)) // top-left
        // Draw path
        edgePoints.forEach { path.addLine(to: $0) }
        
        return path
    }
    
    deinit {
        Logger.verbose()
    }
}
