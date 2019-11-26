//
//  TimerBadgeCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 07/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class TimerBadgeCollectionViewCell: UICollectionViewCell, ReactorKit.View {
    // MARK: - view properties
    private let timerIconImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon_timer"))
        return view
    }()
    
    fileprivate let timerIndexLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(10.adjust())
        view.textColor = Constants.Color.silver
        view.textAlignment = .center
        return view
    }()
    
    fileprivate let timeLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = Constants.Font.ExtraBold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        view.textAlignment = .center
        return view
    }()
    
    let editButton: UIButton = {
        let view = UIButton()
        view.isUserInteractionEnabled = false
        view.setImage(UIImage(named: "btn_timer_edit"), for: .normal)
        return view
    }()
    
    // MARK: - properties
    private var isEnabled: Bool = true
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addAutolayoutSubviews([timerIconImageView, timerIndexLabel, timeLabel, editButton])
        timerIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(timerIconImageView.snp.width)
        }
        
        timerIndexLabel.snp.makeConstraints { make in
            make.leading.equalTo(timerIconImageView.snp.trailing).inset(11.adjust())
            make.trailing.equalTo(timeLabel.snp.leading).inset(-3.adjust())
            make.centerY.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(editButton.snp.leading).inset(-11.adjust())
            make.centerY.equalToSuperview()
        }
        
        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(7.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(2.adjust())
            make.height.equalTo(10.adjust())
        }
        
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func prepareForReuse() {
        setSelected(false)
        disposeBag = DisposeBag()
    }
    
    // MARK: - bind
    func bind(reactor: TimerBadgeCellReactor) {
        // MARK: action
        
        // MARK: state
        reactor.state
            .map { $0.time }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "%02d:%02d:%02d", $0.0, $0.1, $0.2) }
            .map { NSAttributedString(string: $0, attributes: [.kern: -0.36]) }
            .bind(to: timeLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            reactor.state
                .map { $0.index + 1 }
                .distinctUntilChanged(),
            reactor.state
                .map { $0.count }
                .distinctUntilChanged()
            )
            .map { String(format: "timer_badge_index_title_format".localized, $0.0, $0.1) }
            .map { NSAttributedString(string: $0, attributes: [.kern: -0.3]) }
            .bind(to: timerIndexLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isEnabled }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.setEnabled($0) })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isSelected }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.setSelected($0) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    private func initLayout() {
        contentView.backgroundColor = Constants.Color.alabaster
        
        contentView.layer.cornerRadius = 5.adjust()
        contentView.layer.borderColor = Constants.Color.silver.cgColor
        contentView.layer.borderWidth = 0.5
    }
    
    private func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    private func setSelected(_ isSelected: Bool) {
        self.isSelected = isSelected
        
        // Animate border animation
        animateSelection(isSelected)

        // Animate shadow animation
        if isSelected {
            contentView.layer.shadowWithAnimation(alpha: 0.16, offset: CGSize(width: 0, height: 3.adjust()), blur: 6)
        } else {
            contentView.layer.shadowWithAnimation(alpha: 0.16, offset: .zero)
        }
    }
    
    private func animateSelection(_ isSelected: Bool) {
        // Create layer animation
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimation.toValue = (isSelected ? Constants.Color.carnation : Constants.Color.silver).cgColor

        let borderWidthAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidthAnimation.toValue = isSelected ? 1 : 0.5

        // Create animation group
        let animation = CAAnimationGroup()
        animation.animations = [borderColorAnimation, borderWidthAnimation]
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.duration = 0.2

        // Set properties when animation complete
        CATransaction.setCompletionBlock {
            self.contentView.layer.borderColor = (isSelected ? Constants.Color.carnation : Constants.Color.silver).cgColor
            self.contentView.layer.borderWidth = isSelected ? 1 : 0.5
        }
        
        CATransaction.begin()
        contentView.layer.add(animation, forKey: "select")
        CATransaction.commit()
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct TimerBadgeCollectionViewCellPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> TimerBadgeCollectionViewCell {
        return TimerBadgeCollectionViewCell()
    }
    
    func updateUIView(_ uiView: TimerBadgeCollectionViewCell, context: Context) {
        uiView.timerIndexLabel.text = "1/1"
        uiView.timeLabel.text = "00:00:00"
        uiView.editButton.isHidden = false
    }
}

struct Previews_TimerBadgeCollectionViewCellView: PreviewProvider {
    static var previews: some SwiftUI.View {
        Group {
            TimerBadgeCollectionViewCellPreview()
                .frame(width: 130, height: 70)
                .previewLayout(.sizeThatFits)
        }
    }
}

#endif
