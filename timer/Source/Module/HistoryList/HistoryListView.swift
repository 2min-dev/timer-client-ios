//
//  HistoryListView.swift
//  timer
//
//  Created by JSilver on 2019/10/13.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import SnapKit

class HistoryListView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.title = "history_title".localized
        return view
    }()
    
    let historyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset.bottom = 30.adjust()
        layout.minimumInteritemSpacing = 10.adjust()
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.alwaysBounceVertical = true
        view.backgroundColor = Constants.Color.clear
        view.contentInset = UIEdgeInsets(top: 0, left: 20.adjust(), bottom: 0, right: 20.adjust())
        
        // Register cell
        view.register(HistoryListCollectionViewCell.self, forCellWithReuseIdentifier: HistoryListCollectionViewCell.name)
        
        return view
    }()
    
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
    
    lazy var historyListEmptyView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([emptyTitleLabel, createButton, dividerView])
        emptyTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(createButton.snp.top).inset(-30.adjust())
            make.centerX.equalToSuperview()
        }
        
        createButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-42.5.adjust())
        }
        
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(createButton.snp.bottom).inset(5.adjust())
            make.leading.equalTo(createButton)
            make.trailing.equalTo(createButton)
            make.height.equalTo(1)
        }
        
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        // Set constraint of subviews
        addAutolayoutSubviews([headerView, historyCollectionView, historyListEmptyView])
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        historyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        historyListEmptyView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
