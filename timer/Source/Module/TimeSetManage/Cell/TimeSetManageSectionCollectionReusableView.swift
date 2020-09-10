//
//  TimeSetManageSectionCollectionReusableView.swift
//  timer
//
//  Created by JSilver on 11/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetManageSectionCollectionReusableView: UICollectionReusableView {
    // MARK: - view properties
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.bold.withSize(12.adjust())
        view.textColor = R.Color.codGray
        view.text = "time_set_manage_removed_time_set_title".localized
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraints of subviews
        addAutolayoutSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
