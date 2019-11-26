//
//  Toast.swift
//  timer
//
//  Created by JSilver on 2019/11/10.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift

struct ToastTask {
    let title: String
    let handler: () -> Void
}

class Toast: UIView {
    // MARK: - constants
    private static let ANIMATION_DURATION: TimeInterval = 0.5
    private static let AUTOMATIC_POSITION: CGPoint = CGPoint(x: -1, y: -1)
    
    // MARK: - view properties
    let contentLabel: UILabel = {
        let view = UILabel()
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.numberOfLines = 0
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6.adjust()
        
        var attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Font.Bold.withSize(12.adjust()),
            .foregroundColor: Constants.Color.alabaster,
            .kern: -0.36,
            .paragraphStyle: paragraphStyle
        ]
        
        view.attributedText = NSAttributedString(string: " ", attributes: attributes)
        return view
    }()
    
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        
        // Set constraint of subview
        view.addAutolayoutSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalToSuperview().inset(20.adjust()).priorityMedium()
            make.centerY.equalToSuperview()
        }
        
        return view
    }()
    
    let taskButton: UIButton = {
        let view = UIButton()
        
        var attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Font.Bold.withSize(10.adjust()),
            .foregroundColor: Constants.Color.codGray,
            .kern: -0.3
        ]
        
        view.setAttributedTitle(NSAttributedString(string: " ", attributes: attributes), for: .normal)
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [contentContainerView])
        view.axis = .horizontal
        return view
    }()
    
    private var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = Constants.Color.codGray.cgColor
        return layer
    }()
    
    private var taskBorderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 1
        layer.strokeColor = Constants.Color.codGray.cgColor
        layer.fillColor = Constants.Color.alabaster.cgColor
        return layer
    }()
    
    // MARK: - properties
    private var keyWindow: UIWindow? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    private var content: String
    private var task: ToastTask?
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    init(origin: CGPoint = Toast.AUTOMATIC_POSITION, content: String, task: ToastTask? = nil) {
        self.content = content
        self.task = task
        super.init(frame: CGRect(origin: origin, size: .zero))
        
        initLayout()
        bind()
        
        // Set constarint of subviews
        addAutolayoutSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set toast size
        let labelWidth: CGFloat = task == nil ? 290.adjust() : 232.adjust()
        let height = max(48.adjust(), contentLabel.sizeThatFits(CGSize(width: labelWidth, height: 0)).height + 16.adjust())
        frame.size = CGSize(width: 330.adjust(), height: height)
        
        if let keyWindow = keyWindow, frame.origin == Self.AUTOMATIC_POSITION {
            // Set toast position automatically (center x, 82% y)
            let x = (keyWindow.bounds.width - bounds.width) * 0.5
            let y = (keyWindow.bounds.height - keyWindow._safeAreaInsets.bottom) * 0.82
            frame.origin = CGPoint(x: x, y: y)
        }
    }
    
    override func draw(_ rect: CGRect) {
        backgroundLayer.frame = bounds
        taskBorderLayer.frame = taskButton.bounds.insetBy(dx: 0.5, dy: 0.5)
        
        backgroundLayer.path = drawBackgroundLayer(frame: bounds, corner: 5.adjust()).cgPath
        taskBorderLayer.path = drawTaskBorderLayer(frame: taskBorderLayer.bounds, corner: 5.adjust()).cgPath
    }
    
    // MARK: - bind
    private func bind() {
        taskButton.rx.tap
            .do(onNext: { UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .do(onNext: { [weak self] in self?.dismiss(animated: true) })
            .subscribe(onNext: { [weak self] in self?.task?.handler() })
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    private func initLayout() {
        alpha = 0
        // Add sub border layer
        layer.addSublayer(backgroundLayer)
        taskButton.layer.addSublayer(taskBorderLayer)
        
        // Set default content & task
        setContent(content)
        if let task = task {
            setTask(task)
        }
    }
    
    private func setContent(_ content: String) {
        guard let attributedString = contentLabel.attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        attributedString.mutableString.setString(content)
        // Set content label's attributed text
        contentLabel.attributedText = attributedString
        
        self.content = content
    }
    
    private func setTask(_ task: ToastTask) {
        guard let attributedString = taskButton.attributedTitle(for: .normal)?.mutableCopy() as? NSMutableAttributedString else { return }
        attributedString.mutableString.setString(task.title)
        // Set task button's attributed text
        taskButton.setAttributedTitle(attributedString, for: .normal)
        
        // Set constraint of task button
        contentStackView.addArrangedSubview(taskButton)
        taskButton.snp.makeConstraints { make in
            make.width.equalTo(70.adjust()).priorityHigh()
        }
        
        self.task = task
    }
    
    // Draw background layer
    private func drawBackgroundLayer(frame: CGRect, corner radius: CGFloat) -> UIBezierPath {
        // Initial point of border path
        let initialPoint = CGPoint(x: radius, y: 0)
        // Round corner points
        let cornerPoints: [(CGPoint, CGPoint?, CGPoint?)] = [
            // Left-Top
            (CGPoint(x: 0, y: radius),
             CGPoint(x: radius * 0.5, y: 0),
             CGPoint(x: 0, y: radius * 0.5)),
            // Left-Bottom
            (CGPoint(x: 0, y: frame.height - radius), nil, nil),
            (CGPoint(x: radius, y: frame.height),
             CGPoint(x: 0, y: frame.height - radius * 0.5),
             CGPoint(x: radius * 0.5, y: frame.height)),
            // Right-Bottom
            (CGPoint(x: frame.width - radius, y: frame.height), nil, nil),
            (CGPoint(x: frame.width, y: frame.height - radius),
             CGPoint(x: frame.width - radius * 0.5, y: frame.height),
             CGPoint(x: frame.width, y: frame.height - radius * 0.5)),
            // Right-Top
            (CGPoint(x: frame.width, y: radius), nil, nil),
            (CGPoint(x: frame.width - radius, y: 0),
             CGPoint(x: frame.width, y: radius * 0.5),
             CGPoint(x: frame.width - radius * 0.5, y: 0))
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
    
    // Draw task border layer
    private func drawTaskBorderLayer(frame: CGRect, corner radius: CGFloat) -> UIBezierPath {
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
    
    // MARK: - public method
    func show(animated: Bool, withDuration: TimeInterval = -1) {
        guard let keyWindow = keyWindow else { return }
        keyWindow.addSubview(self)
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Self.ANIMATION_DURATION, delay: 0, animations: {
                self.alpha = 1
            })
        } else {
            alpha = 1
        }
        
        if withDuration > 0 {
            Observable<Int>.interval(.milliseconds(Int(withDuration * 1000)), scheduler: MainScheduler.instance)
                .take(1)
                .subscribe(onNext: { [weak self] _ in self?.dismiss(animated: animated) })
                .disposed(by: disposeBag)
        }
    }
    
    func dismiss(animated: Bool) {
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Self.ANIMATION_DURATION, delay: 0, animations: {
                self.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        } else {
            alpha = 0
        }
    }
}
