//
//  HistoryListCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 2019/10/13.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class HistoryListCollectionViewCell: UICollectionViewCell, View {
    // MARK: - view properties
    private let timeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private let startedDateLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    // MARK: - properties
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubviews([timeLabel, startedDateLabel, titleLabel])
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20.adjust())
            make.leading.equalToSuperview().inset(11.adjust())
            make.trailing.equalToSuperview().inset(11.adjust())
        }
        
        startedDateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(9.adjust())
            make.bottom.equalToSuperview().inset(25.adjust())
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(11.adjust())
            make.trailing.equalTo(startedDateLabel.snp.leading)
            make.centerY.equalTo(startedDateLabel)
        }
        
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    func bind(reactor: HistoryListCollectionViewCellReactor) {
        // MARK: action
        
        // MARK: state
        // Title
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Time
        reactor.state
            .map { $0.time }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_time_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.startedDate }
            .distinctUntilChanged()
            .map { getDateString(format: "history_started_date_format".localized, date: $0) }
            .bind(to: startedDateLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    private func initLayout() {
        backgroundColor = Constants.Color.white
        
        layer.cornerRadius = 20.adjust()
        
        layer.borderColor = Constants.Color.gallery.cgColor
        layer.borderWidth = 1
        layer.shadow(alpha: 0.02, offset: CGSize(width: 0, height: 3.adjust()), blur: 4)
    }
}
