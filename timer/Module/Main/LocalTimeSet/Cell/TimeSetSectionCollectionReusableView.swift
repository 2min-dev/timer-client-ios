//
//  TimeSetSectionCollectionReusableView.swift
//  timer
//
//  Created by JSilver on 06/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetSectionCollectionReusableView: UICollectionReusableView {
    enum SectionType {
        case header
        case footer
        
        var backgroundColor: UIColor {
            switch self {
            case .header:
                return Constants.Color.navyBlue
                
            case .footer:
                return Constants.Color.gallery
            }
        }
        
        var foregroundColor: UIColor {
            switch self {
            case .header:
                return Constants.Color.white
                
            case .footer:
                return Constants.Color.carnation
            }
        }
        
        var arrowIconImage: UIImage? {
            switch self {
            case .header:
                return UIImage(named: "icon_arrow_right_white")
                
            case .footer:
                return UIImage(named: "icon_arrow_right_carnation")
            }
        }
    }
    
    // MARK: - view properties
    private let topPaddingView: UIView = {
        return UIView()
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(15.adjust())
        // TODO: sample text. remove it
        view.text = "저장한 타임셋"
        return view
    }()
    
    let additionalTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        // TODO: sample text. remove it
        view.text = "저장한 타임셋 관리"
        return view
    }()
    
    private let arrowIconImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var additionalContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20.adjust()
        layer.shadow(alpha: 0.04, offset: CGSize(width: 0, height: 3.adjust()), blur: 4)
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([additionalTitleLabel, arrowIconImageView])
        additionalTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalTo(arrowIconImageView.snp.leading)
            make.centerY.equalToSuperview()
        }
        
        arrowIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(arrowIconImageView.snp.width)
        }
        
        return view
    }()
    
    private lazy var containerStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [topPaddingView, titleLabel, additionalContainerView])
        view.axis = .vertical
        view.spacing = 15.adjust()
        
        // Set constraint of subviews
        topPaddingView.snp.makeConstraints { make in
            make.height.equalTo(30.adjust())
        }
        
        additionalContainerView.snp.makeConstraints { make in
            make.height.equalTo(40.adjust())
        }
        return view
    }()
    
    // MARK: - properties
    var type: SectionType = .header {
        didSet {
            setType(type)
        }
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraints of subviews
        addAutolayoutSubview(containerStackView)
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private method
    private func setType(_ type: SectionType) {
        topPaddingView.isHidden = type == .footer
        titleLabel.isHidden = type == .footer
        
        additionalContainerView.backgroundColor = type.backgroundColor
        additionalTitleLabel.textColor = type.foregroundColor
        arrowIconImageView.image = type.arrowIconImage
    }
}
