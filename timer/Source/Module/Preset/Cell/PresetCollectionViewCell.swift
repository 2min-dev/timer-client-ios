//
//  PresetCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 2020/01/29.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class PresetCollectionViewCell: UICollectionViewCell, View {
    // MARK: - view properties
    private let timeLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.extraBold.withSize(24.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.bold.withSize(12.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    private let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.bold.withSize(12.adjust())
        view.textColor = R.Color.doveGray
        return view
    }()
    
    private let timerIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.Icon.icTimer
        return view
    }()
    
    private let timerCountLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = R.Font.bold.withSize(12.adjust())
        view.textColor = R.Color.doveGray
        return view
    }()
    
    // MARK: - properties
    var disposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    func bind(reactor: TimeSetCollectionViewCellReactor) {
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
            .map { $0.allTime }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_time_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // End of time set
        Observable.combineLatest(
            reactor.state
                .map { $0.allTime }
                .distinctUntilChanged(),
            Observable<Int>.timer(.seconds(0), period: .seconds(60), scheduler: ConcurrentDispatchQueueScheduler(qos: .default)))
            .observeOn(MainScheduler.instance)
            .map { Date().addingTimeInterval($0.0) }
            .map { getDateString(format: "time_set_end_time_full_format".localized, date: $0, locale: Locale(identifier: Constants.Locale.USA)) }
            .map { String(format: "time_set_end_time_title_format".localized, $0) }
            .bind(to: endOfTimeSetLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Timer count
        reactor.state
            .map { $0.timerCount }
            .distinctUntilChanged()
            .map { String($0) }
            .bind(to: timerCountLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    private func setUpLayout() {
        backgroundColor = R.Color.white
        layer.borderColor = R.Color.gallery.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 20.adjust()
        layer.shadow(alpha: 0.04, offset: CGSize(width: 0, height: 3.adjust()), blur: 4)
        
        // Set constraint of subviews
        addAutolayoutSubviews([timeLabel, endOfTimeSetLabel, titleLabel, timerIconImageView, timerCountLabel])
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20.adjust())
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalToSuperview().inset(15.adjust())
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(3.adjust())
            make.leading.equalTo(timeLabel)
            make.trailing.equalTo(timeLabel)
        }
        
        endOfTimeSetLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20.adjust())
            make.leading.equalTo(timeLabel)
            make.trailing.equalTo(timeLabel)
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10.adjust())
            make.bottom.equalToSuperview().inset(8.adjust())
            make.width.equalTo(36.adjust())
            make.height.equalTo(timerIconImageView.snp.width)
        }
        
        timerCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(timerIconImageView.snp.trailing).inset(4.adjust())
            make.centerY.equalTo(timerIconImageView).offset(1)
        }
    }
}
