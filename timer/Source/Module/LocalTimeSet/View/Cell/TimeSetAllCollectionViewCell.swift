//
//  TimeSetAllCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 2020/01/23.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetAllCollectionViewCell: UICollectionViewCell {
    // MARK: - view properties
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.carnation
        return view
    }()
    
    private let arrowIconImageView: UIImageView = UIImageView(image: R.Icon.icArrowRightCarnation)
    
    // MARK: - properties
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private method
    private func setUpLayout() {
        backgroundColor = Constants.Color.gallery
        layer.cornerRadius = 20.adjust()
        
        // Set constraints of subviews
        addAutolayoutSubviews([titleLabel, arrowIconImageView])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalTo(arrowIconImageView.snp.leading).inset(-10.adjust())
            make.centerY.equalToSuperview()
        }
        
        arrowIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(arrowIconImageView.snp.width)
        }
    }
}
