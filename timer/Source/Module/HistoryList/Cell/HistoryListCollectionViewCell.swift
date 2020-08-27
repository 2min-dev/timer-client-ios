//
//  HistoryListCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 2019/10/13.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import JSSwipeableCell

class HistoryListCollectionViewCell: JSSwipeableCollectionViewCell, View {
    // MARK: - view properties
    private let runningTimeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    private let startedDateLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = R.Color.doveGray
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    fileprivate let deleteButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.font = Constants.Font.Bold.withSize(12)
        view.setTitle("history_delete_title".localized, for: .normal)
        view.backgroundColor = R.Color.carnation
        return view
    }()
    
    // MARK: - properties
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - bind
    func bind(reactor: HistoryListCollectionViewCellReactor) {
        // MARK: action
        deleteButton.rx.tap
            .subscribe(onNext: { Logger.debug() })
            .disposed(by: disposeBag)
        
        // MARK: state
        // Title
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Running time
        reactor.state
            .map { $0.time }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_time_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: runningTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Started date
        reactor.state
            .map { $0.startedDate }
            .distinctUntilChanged()
            .map { getDateString(format: "history_started_date_format".localized, date: $0, locale: Locale(identifier: Constants.Locale.USA)) }
            .bind(to: startedDateLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    private func setUpLayout() {
        backgroundColor = R.Color.white
        layer.masksToBounds = true
        layer.cornerRadius = 20.adjust()
        layer.borderColor = R.Color.gallery.cgColor
        layer.borderWidth = 1
        layer.shadow(alpha: 0.02, offset: CGSize(width: 0, height: 3.adjust()), blur: 4)
        
        contentView.backgroundColor = R.Color.white
        
        // Set constraint of subviews
        contentView.addAutolayoutSubviews([runningTimeLabel, startedDateLabel, titleLabel])
        runningTimeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(25.adjust())
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
        
        // Set swipe action views
        rightActionView.addAutolayoutSubviews([deleteButton])
        deleteButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(70.adjust())
        }
    }
}

extension Reactive where Base: HistoryListCollectionViewCell {
    var delete: ControlEvent<Void> { base.deleteButton.rx.tap }
}
