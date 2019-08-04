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
    static let ReuseableIdentifier = "TimerBadgeAddCollectionViewCell"
    
    // MARK: - view properties
    let addLabel: UILabel = {
        let view = UILabel()
        view.text = "+"
        view.textColor = Constants.Color.codGray
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textAlignment = .center
        return view
    }()
    
    private lazy var containerView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = Constants.Color.gallery
        
        // Set constraint of subviews
        view.addAutolayoutSubview(self.addLabel)
        addLabel.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 5.adjust(), left: 6.adjust(), bottom: 5.adjust(), right: 6.adjust()))
        }
        
        return view
    }()
    
    // MARK: - properties
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addAutolayoutSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(31.adjust())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = containerView.bounds.height / 2
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
