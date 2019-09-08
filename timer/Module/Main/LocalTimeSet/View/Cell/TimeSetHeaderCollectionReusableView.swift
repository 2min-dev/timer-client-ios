//
//  TimeSetHeaderCollectionReusableView.swift
//  timer
//
//  Created by JSilver on 06/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetHeaderCollectionReusableView: UICollectionReusableView {
    // MARK: - view properties
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.numberOfLines = 0
        view.text = "주로 쓰는 타임셋을 모아보세요,\n시간을 관리하는 데 도움이 될 거에요 :)"
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraints of subviews
        addAutolayoutSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(10.adjust())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
