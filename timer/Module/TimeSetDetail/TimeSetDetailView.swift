//
//  TimeSetDetailView.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetDetailView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.buttonTypes = [.share, .bookmark, .home]
        return view
    }()
    
    let root: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        addAutolayoutSubviews([headerView, root])
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        root.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
