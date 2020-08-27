//
//  NoticeDetailView.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class NoticeDetailView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        return view
    }()
    
    let noticeTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = R.Color.clear
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = R.Color.carnation
        view.isEditable = false
        view.textContainer.lineFragmentPadding = 30
        view.textContainerInset = UIEdgeInsets(top: 22.adjust(), left: 0, bottom: 22.adjust(), right: 0)
        return view
    }()
    
    let loadingView: CommonLoading = {
        return CommonLoading()
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = R.Color.alabaster
        
        // Set constrain of subviews
        addAutolayoutSubviews([noticeTextView, headerView, loadingView])
        noticeTextView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
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
