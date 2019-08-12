//
//  TimeSetBadge.swift
//  timer
//
//  Created by JSilver on 12/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimeSetBadge: UIView {
    enum BadgeType {
        case countdown(time: Int)
        case loop(count: Int)
        case cancel
        case excess
        
        var text: String {
            switch self {
            case let .countdown(time: time):
                return "시작 \(time)초 전"
            case let .loop(count: count):
                return "\(count)회 반복"
            case .cancel:
                return "취소 타임셋"
            case .excess:
                return "초과 타임셋"
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .countdown(time: _): fallthrough
            case .loop(count: _):
                return Constants.Color.codGray
            case .cancel: fallthrough
            case .excess:
                return Constants.Color.white
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .countdown(time: _): fallthrough
            case .loop(count: _):
                return Constants.Color.white
            case .cancel:
                return Constants.Color.navyBlue
            case .excess:
                return Constants.Color.carnation
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .countdown(time: _): fallthrough
            case .loop(count: _):
                return 1
            default:
                return 0
            }
        }
    }
    
    // MARK: - view properties
    let textLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = Constants.Color.codGray.cgColor
    
        // Set constraint of subviews
        view.addAutolayoutSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    // MARK: - properties
    var text: String {
        set { textLabel.text = newValue }
        get { return textLabel.text! }
    }
    var font: UIFont {
        set { textLabel.font = newValue }
        get { return textLabel.font }
    }
    
    override var intrinsicContentSize: CGSize {
        var width = textLabel.sizeThatFits(bounds.size).width + 20
        return CGSize(width: width > 80.adjust() ? width : 80.adjust(), height: 20.adjust())
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public method
    func setType(_ type: BadgeType) {
        textLabel.text = type.text
        textLabel.textColor = type.textColor
        containerView.backgroundColor = type.backgroundColor
        containerView.layer.borderWidth = type.borderWidth
    }
}

extension Reactive where Base: TimeSetBadge {
    var type: Binder<Base.BadgeType> {
        return Binder(base.self) { _, type in
            self.base.setType(type)
        }
    }
}
