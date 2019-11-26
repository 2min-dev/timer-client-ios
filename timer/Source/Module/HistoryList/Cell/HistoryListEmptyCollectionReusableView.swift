//
//  HistoryListEmptyCollectionReusableView.swift
//  timer
//
//  Created by JSilver on 2019/10/14.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class HistoryListEmptyCollectionReusableView: UICollectionReusableView {
    // MARK: - view properties
    private let emptyTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        
        let string = "history_empty_title".localized
        
        // Create paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 10.adjust()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Font.Regular.withSize(15.adjust()),
            .foregroundColor: Constants.Color.codGray,
            .paragraphStyle: paragraphStyle,
            .kern: -0.45
        ]
        // Set attributed string
        view.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        return view
    }()
    
    let createButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.textAlignment = .center
        
        let string = "history_make_time_set_title".localized
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Font.Regular.withSize(15.adjust()),
            .foregroundColor: Constants.Color.carnation,
            .kern: -0.45
        ]
        // Set attributed string
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        return view
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.carnation
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubviews([emptyTitleLabel, createButton, dividerView])
        emptyTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(createButton.snp.top).inset(-30.adjust())
            make.centerX.equalToSuperview()
        }
        
        createButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(createButton.snp.bottom).inset(5.adjust())
            make.leading.equalTo(createButton)
            make.trailing.equalTo(createButton)
            make.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
