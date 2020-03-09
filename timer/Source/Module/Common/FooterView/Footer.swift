//
//  Footer.swift
//  timer
//
//  Created by JSilver on 02/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Footer: UIView {
    // MARK: - view properties
    var buttons: [FooterButton] = [] {
        didSet {
            containerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            buttons.forEach { containerStackView.addArrangedSubview($0) }
        }
    }
    
    private lazy var containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 10.adjust()
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubview(containerStackView)
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 23.adjust(), bottom: 14.adjust(), right: 23.adjust())).priority(.high)
            make.height.equalTo(50.adjust())
        }
        
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        // Set constraint of subviews
        addAutolayoutSubview(containerView)
        containerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: Footer {
    var tap: ControlEvent<Int> {
        let source: Observable<Int> = .merge(base.buttons.enumerated().map { index, button in
            button.rx.tap.map { index }
        })
        return ControlEvent(events: source)
    }
}
