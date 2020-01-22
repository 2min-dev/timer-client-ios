//
//  PresetView.swift
//  timer
//
//  Created by JSilver on 2019/11/30.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class PresetView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.backButton.isHidden = true
        view.additionalButtons = [.history, .setting]
        view.title = "preset_title".localized
        return view
    }()
    
    let timeSetCollectionView: UICollectionView = {
        let layout = JSCollectionViewLayout()
        layout.globalInset = UIEdgeInsets(top: 20.adjust(), left: 0, bottom: 40.adjust(), right: 0)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = Constants.Color.clear
        view.contentInset = UIEdgeInsets(top: 0, left: 20.adjust(), bottom: 0, right: 20.adjust())
        
        // Register supplimentary view
        view.register(TimeSetHeaderCollectionReusableView.self, forSupplementaryViewOfKind: JSCollectionViewLayout.Element.header.kind, withReuseIdentifier: TimeSetHeaderCollectionReusableView.name)
        // Register cell
        view.register(SavedTimeSetSmallCollectionViewCell.self, forCellWithReuseIdentifier: SavedTimeSetSmallCollectionViewCell.name)
        
        return view
    }()
    
    let loadingView: CommonLoading = CommonLoading()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        // Set contraints of subviews
        addAutolayoutSubviews([timeSetCollectionView, headerView, loadingView])
        timeSetCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide).priorityHigh()
            } else {
                make.bottom.equalToSuperview().priorityHigh()
            }
        }
        
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
