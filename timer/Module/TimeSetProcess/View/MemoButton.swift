//
//  MemoButton.swift
//  timer
//
//  Created by JSilver on 12/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class MemoButton: UIButton {
    // MARK: - view properties
    private let textLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.text = "time_set_process_memo_title".localized
        view.textColor = Constants.Color.white
        view.font = Constants.Font.ExtraBold.withSize(12.adjust())
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.navyBlue
    
        // Set constraint of subviews
        view.addAutolayoutSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    // MARK: - properties
    
    override var intrinsicContentSize: CGSize {
        let width = textLabel.sizeThatFits(bounds.size).width + 20
        return CGSize(width: width > 42.adjust() ? width : 42.adjust(), height: 30.adjust())
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(view: containerView, byRoundingCorners: [.topRight, .bottomRight], cornerRadius: containerView.bounds.height / 2)
    }
}
