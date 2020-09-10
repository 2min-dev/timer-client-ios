//
//  TimerBadgeAddCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 2019/07/08.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift

class TimerBadgeAddCollectionViewCell: UICollectionViewCell {
    // MARK: - view properties
    let addLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.extraBold.withSize(18.adjust())
        view.textColor = R.Color.codGray
        view.text = "+"
        view.textAlignment = .center
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = R.Color.gallery
        
        // Set constraint of subviews
        view.addAutolayoutSubview(addLabel)
        addLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    // MARK: - properties
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = R.Color.clear
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Set contraint of subviews
        contentView.addAutolayoutSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(containerView.snp.height)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func draw(_ rect: CGRect) {
        containerView.layer.cornerRadius = containerView.bounds.height / 2
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
