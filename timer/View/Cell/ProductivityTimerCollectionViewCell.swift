//
//  ProductivityTimerCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 07/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class ProductivityTimerCollectionViewCell: UICollectionViewCell, View {
    // MARK: - view properties
    let timeLabel: UILabel = {
        let view = UILabel()
        view.textColor = Constants.Color.white
        view.font = Constants.Font.Regular.withSize(12.adjust())
        return view
    }()
    
    private lazy var containerView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = Constants.Color.black
        view.addAutolayoutSubview(self.timeLabel)
        return view
    }()
    
    // MARK: - properties
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.clear

        addAutolayoutSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5.adjust())
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(5.adjust())
            make.height.equalTo(28).priority(999) // To solve autolayout warning
        }

        timeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 5))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(view: containerView, byRoundingCorners: [.bottomLeft, .topLeft], cornerRadius: containerView.bounds.height / 2)
    }
    
    // MARK: - reactor bind
    func bind(reactor: ProductivityTimerCollectionViewCellReactor) {
        // MARK: action
        
        // MARK: state
        reactor.state
            .map { $0.time }
            .map {
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .positional
                formatter.allowedUnits = [.hour, .minute, .second]
                return formatter.string(from: $0) ?? ""
            }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        Logger.debug()
    }
}
