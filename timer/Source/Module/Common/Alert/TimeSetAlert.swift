//
//  TimeSetAlert.swift
//  timer
//
//  Created by JSilver on 28/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimeSetAlert: UIView {
    enum AlertType {
        case cancel
        case confirm
    }
    
    // MARK: - view properties
    private let textLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        
        return view
    }()
    
    fileprivate let cancelButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_clear"), for: .normal)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([textLabel, cancelButton])
        textLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalTo(cancelButton.snp.leading).inset(-5)
            make.centerY.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(5.adjust())
            make.bottom.equalToSuperview()
            make.width.equalTo(36.adjust())
        }
        
        return view
    }()
    
    private let confirmLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = Constants.Color.carnation.cgColor
        layer.strokeColor = Constants.Color.codGray.cgColor
        layer.lineWidth = 1
        return layer
    }()
    
    fileprivate lazy var confirmButton: UIButton = {
        let view = UIButton()
        view.layer.insertSublayer(confirmLayer, below: view.imageView?.layer)
        
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
    
    private lazy var containerStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [contentView, confirmButton])
        view.layer.insertSublayer(containerLayer, at: 0)
        
        // Set constraint of subviews
        contentView.snp.makeConstraints { make in
            make.width.equalTo(200.adjust())
        }
        
        confirmButton.snp.makeConstraints { make in
            make.width.equalTo(50.adjust())
        }
        
        return view
    }()
    
    // MARK: - properties
    private let tailSize = CGSize(width: 12.adjust(), height: 8.adjust())
    private let tailPosition = CGPoint(x: 19.adjust(), y: 54.adjust())
    
    private let text: String
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    init(text: String, type: AlertType = .cancel) {
        self.text = text
        super.init(frame: .zero)
        
        initLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func draw(_ rect: CGRect) {
        containerLayer.frame = containerStackView.bounds
        containerLayer.path = drawBackgroundLayer(frame: containerLayer.bounds, corner: 5.adjust()).cgPath
        
        confirmLayer.frame = confirmButton.bounds
        confirmLayer.path = drawConfirmBorderLayer(frame: confirmLayer.bounds, corner: 5.adjust()).cgPath
    }
    
    // MARK: - bind
    private func bind() {
        Observable.merge(
            cancelButton.rx.tap.asObservable(),
            confirmButton.rx.tap.asObservable())
            .subscribe(onNext: { [weak self] in self?.removeFromSuperview() })
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    private func initLayout() {
        // Create paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8.adjust()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Font.Bold.withSize(12.adjust()),
            .foregroundColor: Constants.Color.codGray,
            .kern: -0.36,
            .paragraphStyle: paragraphStyle
        ]
        
        // Set attributed string
        textLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        
        // Set constraint of subviews
        addAutolayoutSubview(containerStackView)
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(54.adjust())
        }
    }
    
    private func drawBackgroundLayer(frame: CGRect, corner radius: CGFloat) -> UIBezierPath {
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
        let initialPoint = CGPoint(x: 0, y: 0)
        // Round corner points
        let cornerPoints: [(CGPoint, CGPoint?, CGPoint?)] = [
            // Left-Bottom
            (CGPoint(x: 0, y: frame.height), nil, nil),
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
            (CGPoint(x: -0.5, y: 0), nil, nil)
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

extension Reactive where Base: TimeSetAlert {
    var cancel: ControlEvent<Void> {
        return ControlEvent(events: base.cancelButton.rx.tap)
    }
    
    var confirm: ControlEvent<Void> {
        return ControlEvent(events: base.confirmButton.rx.tap)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct AlertPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> TimeSetAlert {
        return TimeSetAlert(text: "Hello world!")
    }
    
    func updateUIView(_ uiView: TimeSetAlert, context: Context) {
        // Nothing
    }
}

struct Previews_AlertEditView: PreviewProvider {
    static var previews: some View {
        Group {
            AlertPreview()
                .previewLayout(.fixed(width: 250, height: 54))
        }
    }
}

#endif
