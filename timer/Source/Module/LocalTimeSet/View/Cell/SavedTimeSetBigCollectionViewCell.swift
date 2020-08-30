//
//  SavedTimeSetBigCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 06/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class SavedTimeSetBigCollectionViewCell: UICollectionViewCell, View {
    enum CellType {
        case normal
        case highlight
        
        var backgroundColor: UIColor {
            switch self {
            case .normal:
                return R.Color.white
                
            case .highlight:
                return R.Color.carnation
            }
        }
        
        var titleColor: UIColor {
            switch self {
            case .normal:
                return R.Color.codGray
                
            case .highlight:
                return R.Color.white
            }
        }
        
        var subtitleColor: UIColor {
            switch self {
            case .normal:
                return R.Color.doveGray
                
            case .highlight:
                return R.Color.gallery
            }
        }
        
        var timerIconImage: UIImage? {
            switch self {
            case .normal:
                return R.Icon.icTimer
                
            case .highlight:
                return R.Icon.icTimerWhite
            }
        }
    }
    
    // MARK: - view properties
    private let timeLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.extraBold.withSize(24.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    private let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = R.Font.bold.withSize(12.adjust())
        view.textColor = R.Color.doveGray
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.bold.withSize(12.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    private let timerIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.Icon.icTimerWhite
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
    var type: CellType = .normal {
        didSet { setCellType(type) }
    }
    
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
        layer.shadow(alpha: 0.04, offset: CGSize(width: 0, height: 3.adjust()), blur: 4)
        layer.borderColor = R.Color.gallery.cgColor
        layer.cornerRadius = 20.adjust()
        setCellType(type)
        
        // Set constraint of subviews
        addAutolayoutSubviews([timeLabel, endOfTimeSetLabel, titleLabel, timerIconImageView, timerCountLabel])
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30.adjust())
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalTo(endOfTimeSetLabel.snp.leading).inset(-10.adjust())
        }
        
        endOfTimeSetLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.adjust())
            make.centerY.equalTo(timeLabel)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalTo(timerIconImageView.snp.leading)
            make.bottom.equalToSuperview().inset(30.adjust())
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.trailing.equalTo(timerCountLabel.snp.leading).offset(4.adjust())
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(36.adjust())
            make.height.equalTo(timerIconImageView.snp.width)
        }
        
        timerCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.adjust())
            make.centerY.equalTo(titleLabel).offset(1)
        }
    }
    
    private func setCellType(_ type: CellType) {
        backgroundColor = type.backgroundColor
        layer.borderWidth = type == .normal ? 1 : 0
        
        timeLabel.textColor = type.titleColor
        titleLabel.textColor = type.titleColor
        endOfTimeSetLabel.textColor = type.subtitleColor
        timerCountLabel.textColor = type.subtitleColor
        
        timerIconImageView.image = type.timerIconImage
    }
}
