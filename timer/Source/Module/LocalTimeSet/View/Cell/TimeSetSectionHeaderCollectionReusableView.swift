//
//  TimeSetSectionHeaderCollectionReusableView.swift
//  timer
//
//  Created by JSilver on 06/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimeSetSectionHeaderCollectionReusableView: UICollectionReusableView {
    // MARK: - view properties
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(15.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    fileprivate let additionalButton: UIButton = {
        let view = UIButton()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.isHidden = true // Default `hidden`
         
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Font.Bold.withSize(12.adjust()),
            .foregroundColor: R.Color.codGray,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .kern: -0.36
        ]
        
        view.setAttributedTitle(NSAttributedString(string: " ", attributes: attributes), for: .normal)
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, additionalButton])
        view.axis = .horizontal
        view.spacing = 10.adjust()
        return view
    }()
    
    // MARK: - properties
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var additionalText: String? {
        get { additionalButton.titleLabel?.text }
        set {
            // Set hidden if value is `nil`
            additionalButton.isHidden = newValue == nil
            
            guard let string = newValue,
                let attributedString = additionalButton.attributedTitle(for: .normal)?.setString(string) else { return }
            additionalButton.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        title = nil
        additionalText = nil
        
        disposeBag = DisposeBag()
    }
    
    // MARK: - private method
    private func setUpLayout() {
        // Set constraints of subviews
        addAutolayoutSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(28.adjust())
        }
    }
}

extension Reactive where Base: TimeSetSectionHeaderCollectionReusableView {
    var tap: ControlEvent<Void> {
        ControlEvent(events: base.additionalButton.rx.tap)
    }
}
