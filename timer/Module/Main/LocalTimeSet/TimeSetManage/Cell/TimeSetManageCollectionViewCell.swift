//
//  TimeSetManageCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 10/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class TimeSetManageCollectionViewCell: UICollectionViewCell, View {
    // MARK: - view properties
    let editButton: UIButton = {
        let view = UIButton()
        return view
    }()
    
    private let timeLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = Constants.Color.codGray
        // TODO: sample text. remove it.
        view.text = "00:00:00"
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        // TODO: sample text. remove it.
        view.text = "타임셋 명"
        return view
    }()
    
    let reorderButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_change"), for: .normal)
        return view
    }()
    
    // MARK: - properties
    var disposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubviews([editButton, timeLabel, titleLabel, reorderButton])
        editButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(editButton.snp.width)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(editButton.snp.trailing).offset(1)
            make.centerY.equalTo(editButton)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(timeLabel.snp.trailing).offset(16.adjust())
            make.trailing.equalTo(reorderButton.snp.leading)
            make.centerY.equalTo(timeLabel)
        }
        
        reorderButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(reorderButton.snp.width)
        }
        
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private method
    private func initLayout() {
        backgroundColor = Constants.Color.white
        layer.borderColor = Constants.Color.gallery.cgColor
        layer.borderWidth = 1
    }
    
    // MARK: - bind
    func bind(reactor: TimeSetManageCollectionViewCellReactor) {
        // MARK: action
        
        // MARK: state
        // Edit
        reactor.state
            .map { $0.type }
            .distinctUntilChanged()
            .map { UIImage(named: $0 == .normal ? "btn_timeset_delete" : "btn_timeset_recover") }
            .bind(to: editButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        // Time
        reactor.state
            .map { $0.allTime }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_time_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Title
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
