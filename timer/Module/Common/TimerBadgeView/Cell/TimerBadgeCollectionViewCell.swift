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

class TimerBadgeCollectionViewCell: UICollectionViewCell, View {
    static let ReuseableIdentifier = "TimerBadgeCollectionViewCell"
    
    // MARK: - view properties
    private let timeLabel: UILabel = {
        let view = UILabel()
        view.textColor = Constants.Color.white
        view.font = Constants.Font.ExtraBold.withSize(12.adjust())
        view.textAlignment = .center
        return view
    }()
    
    private lazy var containerView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = Constants.Color.black

        // Set constraint of subviews
        view.addAutolayoutSubview(self.timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 5.adjust(), left: 6.adjust(), bottom: 5.adjust(), right: 6.adjust()))
        }

        return view
    }()

    let optionButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_timer_detail"), for: .normal)
        view.contentVerticalAlignment = .bottom
        return view
    }()

    let indexLabel: UILabel = {
        let view = UILabel()
        view.textColor = Constants.Color.gray
        view.font = Constants.Font.ExtraBold.withSize(10.adjust())
        view.textAlignment = .center
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
        
        contentView.addAutolayoutSubviews([optionButton, containerView, indexLabel])
        optionButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(containerView.snp.top).offset(-5.adjust())
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(29.adjust())
        }
        
        indexLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(5.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
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
        setSelected(false)
        disposeBag = DisposeBag()
    }
    
    // MARK: - reactor bind
    func bind(reactor: TimerBadgeCellReactor) {
        // MARK: action
        
        // MARK: state
        reactor.state
            .map { $0.time }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "%02d:%02d:%02d", $0.0, $0.1, $0.2) }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { String($0.index) }
            .distinctUntilChanged()
            .bind(to: indexLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isSelected }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.setSelected($0) })
            .disposed(by: disposeBag)
    }
    
    private func setSelected(_ isSelected: Bool) {
        guard let reactor = reactor else { return }
        
        // Set time label color
        containerView.backgroundColor = isSelected ? Constants.Color.black : Constants.Color.clear
        timeLabel.textColor = isSelected ? Constants.Color.white : Constants.Color.black
        
        // Set option button visible
        optionButton.isHidden = !reactor.currentState.isOptionVisible || !isSelected
    }
}
