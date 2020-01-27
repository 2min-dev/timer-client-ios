//
//  TimeSetManageView.swift
//  timer
//
//  Created by JSilver on 10/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import JSReorderableCollectionView

class TimeSetManageView: UIView {
    // MARK: - view properties
    let headerView: ConfirmHeader = {
        let view = ConfirmHeader()
        view.title = "saved_time_set_management_title".localized
        return view
    }()
    
    let timeSetCollectionView: JSReorderableCollectionView = {
        let layout = JSCollectionViewLayout()
        layout.globalInset.top = 16.adjust()
        layout.sectionInset = UIEdgeInsets(top: 10.adjust(), left: 0, bottom: 40.adjust(), right: 0)
        
        let view = JSReorderableCollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = Constants.Color.clear
        view.contentInset = UIEdgeInsets(top: 0, left: 20.adjust(), bottom: 0, right: 20.adjust())
        view.isAxisFixed = true
        
        // Register supplimentary view
        view.register(TimeSetManageHeaderCollectionReusableView.self, forSupplementaryViewOfKind: JSCollectionViewLayout.Element.header.kind, withReuseIdentifier: TimeSetManageHeaderCollectionReusableView.name)
        view.register(TimeSetManageSectionCollectionReusableView.self, forSupplementaryViewOfKind: JSCollectionViewLayout.Element.sectionHeader.kind, withReuseIdentifier: TimeSetManageSectionCollectionReusableView.name)
        // Register cell
        view.register(TimeSetManageCollectionViewCell.self, forCellWithReuseIdentifier: TimeSetManageCollectionViewCell.name)
        
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        addAutolayoutSubviews([timeSetCollectionView, headerView])
        timeSetCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
