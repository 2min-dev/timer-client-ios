//
//  TimerBadgeRepeatCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 23/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class TimerBadgeRepeatCollectionViewCell: UICollectionViewCell, View {
    // MARK: - view properties
    private let repeatButton: UIButton = {
        let view = UIButton()
        view.setImage(R.Icon.icBtnRepeatOff, for: .normal)
        view.setImage(R.Icon.icBtnRepeatOn, for: .selected)
        view.setImage(R.Icon.icBtnRepeatDisable, for: .disabled)
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.gallery
        
        // Set constraint of subviews
        view.addAutolayoutSubview(repeatButton)
        repeatButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    // MARK: - properties
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.clear
        
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
    
    // MARK: - bind
    func bind(reactor: TimerBadgeRepeatCellReactor) {
        // MARK: action
        repeatButton.rx.tap
            .do(onNext: { UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .map { .toggleRepeat }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        // Repeat
        reactor.state
            .map { $0.isRepeat }
            .distinctUntilChanged()
            .bind(to: repeatButton.rx.isSelected)
            .disposed(by: disposeBag)
    }
}
