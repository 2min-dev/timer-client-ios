//
//  TimeSetProcessFloatingView.swift
//  timer
//
//  Created by JSilver on 02/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class TimeSetProcessFloatingView: UIView, View {
    // MARK: - view properties
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(10.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let timeLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private let timerIconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = UIImage(named: "icon_timer")
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let view = UILabel()
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.font = Constants.Font.Bold.withSize(10.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private let playButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_play"), for: .normal)
        view.setImage(UIImage(named: "btn_pause"), for: .selected)
        return view
    }()
    
    let closeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_clear"), for: .normal)
        return view
    }()
    
    // MARK: - properties
    var disposeBag = DisposeBag()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 55.adjust())
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.gallery
        
        addAutolayoutSubviews([titleLabel, timeLabel, timerIconImageView, subtitleLabel, playButton, closeButton])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10.adjust())
            make.leading.equalToSuperview().inset(40.adjust())
            make.trailing.equalTo(playButton.snp.leading).inset(-10.adjust())
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(12.adjust())
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.leading.equalTo(timeLabel.snp.trailing).offset(5.adjust())
            make.centerY.equalTo(timeLabel)
            make.width.equalTo(36.adjust())
            make.height.equalTo(closeButton.snp.width)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(timerIconImageView.snp.trailing).inset(5.adjust())
            make.trailing.equalTo(playButton.snp.leading).inset(-10.adjust())
            make.centerY.equalTo(timeLabel)
        }
        
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(closeButton.snp.width)
        }
        
        playButton.snp.makeConstraints { make in
            make.trailing.equalTo(closeButton.snp.leading).inset(-10.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(closeButton.snp.width)
        }
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(gesture:)))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetProcessFloatingViewReactor) {
        // MARK: action
        
        playButton.rx.tap
            .map { [unowned self] in self.mapTimeSetActionFromPlayButton(self.playButton) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        // Title
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Remained time
        reactor.state
            .map { $0.remainedTime }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_time_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Subtitle
        Observable.combineLatest(
            reactor.state
                .map { $0.currentIndex }
                .distinctUntilChanged(),
            reactor.state
                .map { $0.count }
                .distinctUntilChanged(),
            reactor.state
                .map { $0.repeatCount }
                .distinctUntilChanged())
            .map { [weak self] in self?.getTimeSetInfoString(index: $0.0, count: $0.1, repeatCount: $0.2) }
            .bind(to: subtitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Play button
        reactor.state
            .map { $0.timeSetState }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.updatePlayButtonByState($0) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    private func mapTimeSetActionFromPlayButton(_ button: UIButton) -> TimeSetProcessFloatingViewReactor.Action {
        if button.isSelected {
            return Reactor.Action.pauseTimeSet
        } else {
            return Reactor.Action.startTimeSet
        }
    }
    
    // MARK: - state method
    /// Get time set process info string
    private func getTimeSetInfoString(index: Int, count: Int, repeatCount: Int) -> String {
        var string = String(format: "time_set_floating_timer_end_info_format".localized, index + 1, count)
        if repeatCount > 0 {
            string += String(format: " " + "time_set_floating_time_set_repeat_info_format".localized, repeatCount)
        }
        
        return string
    }
    
    /// Update play/pause button state by time set state
    private func updatePlayButtonByState(_ state: TimeSet.State) {
        switch state {
        case .run(detail: _):
            playButton.isSelected = true
            
        case .pause:
            playButton.isSelected = false
            
        default:
            break
        }
    }
    
    // MARK: - selector
    @objc fileprivate func tapHandler(gesture: UITapGestureRecognizer) {
        
    }
}

extension Reactive where Base: TimeSetProcessFloatingView {
    var tap: ControlEvent<Void> {
        return ControlEvent(events: methodInvoked(#selector(base.tapHandler(gesture:))).map { _ in Void() })
    }
}
