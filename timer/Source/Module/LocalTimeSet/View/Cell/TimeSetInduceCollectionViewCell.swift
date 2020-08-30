//
//  TimeSetInduceCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 08/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetInduceCollectionViewCell: UICollectionViewCell {
    // MARK: - view properties
    private let plusIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.Icon.icBtnTimesetAdd
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.bold.withSize(12.adjust())
        view.textColor = R.Color.codGray
        view.text = "time_set_induce_title".localized
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubviews([plusIconImageView, descriptionLabel])
        plusIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40.adjust())
            make.centerX.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(plusIconImageView.snp.width)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(plusIconImageView.snp.bottom).inset(-22.adjust())
            make.centerX.equalToSuperview()
        }
        
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private method
    private func initLayout() {
        backgroundColor = R.Color.white
        layer.shadow(alpha: 0.04, offset: CGSize(width: 0, height: 3.adjust()), blur: 4)
        layer.borderColor = R.Color.gallery.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 20.adjust()
    }
}
