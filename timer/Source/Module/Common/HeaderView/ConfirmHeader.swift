//
//  ConfirmHeader.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ConfirmHeader: Header {
    // MARK: - view properties
    let cancelButton: UIButton = {
        let view = UIButton()
        view.setTitle("header_button_cancel".localized, for: .normal)
        view.setTitleColor(Constants.Color.codGray, for: .normal)
        view.titleLabel?.font = Constants.Font.Regular.withSize(15.adjust())
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let confirmButton: UIButton = {
        let view = UIButton()
        view.setTitle("header_button_confirm".localized, for: .normal)
        view.setTitleColor(Constants.Color.codGray, for: .normal)
        view.titleLabel?.font = Constants.Font.Regular.withSize(15.adjust())
        return view
    }()
    
    // MARK: - properties
    override var title: String? {
        set { titleLabel.text = newValue }
        get { return titleLabel.text }
    }
    
    // MARK: - properties
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 75.adjust())
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        // Set constraint of subviews
        addAutolayoutSubviews([cancelButton, titleLabel, confirmButton])
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.adjust())
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200.adjust())
        }
        
        confirmButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.adjust())
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    override func bind() {
        cancelButton.rx.tap
            .map { .cancel }
            .bind(to: action)
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .map { .confirm }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
}
