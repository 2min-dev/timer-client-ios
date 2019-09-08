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
        view.image = UIImage(named: "btn_timeset_add")
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        view.text = "타임셋을 추가해보세요!"
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
        backgroundColor = Constants.Color.white
        layer.shadow(alpha: 0.04, offset: CGSize(width: 0, height: 3.adjust()), blur: 4)
        layer.borderColor = Constants.Color.gallery.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 20.adjust()
    }
}
