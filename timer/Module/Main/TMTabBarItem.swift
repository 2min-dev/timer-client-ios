//
//  TMTabBarItem.swift
//  timer
//
//  Created by JSilver on 29/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TMTabBarItem: UIButton {
    // MARK: - view properties
    let title: UILabel = {
        let view = UILabel()
        view.isHidden = true
        return view
    }()
    
    let icon: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        return view
    }()
    
    private lazy var tabBarItemStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [icon, title])
        view.isUserInteractionEnabled = false
        view.axis = .vertical
        view.alignment = .center
        
        icon.snp.makeConstraints { make in
            make.width.equalTo(icon.snp.height)
        }
        
        return view
    }()
    
    // MARK: - properties
    override var isSelected: Bool {
        didSet {
            title.textColor = isSelected ? tintColor : .black
            icon.tintColor = isSelected ? tintColor : .black
        }
    }
    
    // MARK: - contructor
    init(title: String? = nil, icon: UIImage? = nil) {
        super.init(frame: .zero)
        isSelected = false
        
        addAutolayoutSubview(tabBarItemStackView)
        tabBarItemStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
        }
        
        // Add title label if title is existed
        if let title = title {
            self.title.isHidden = false
            self.title.text = title
        }
        
        // Add icon image view if icon is existed
        if let icon = icon {
            self.icon.isHidden = false
            self.icon.image = icon.withRenderingMode(.alwaysTemplate)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
