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
    // MARK: - view properties
    private let timeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(12.adjust())
        view.textColor = Constants.Color.white
        view.textAlignment = .center
        return view
    }()
    
    private lazy var containerView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = Constants.Color.codGray
        view.layer.borderWidth = 1

        // Set constraint of subviews
        view.addAutolayoutSubview(self.timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 5.adjust(), left: 6.adjust(), bottom: 5.adjust(), right: 6.adjust()))
        }

        return view
    }()

    let optionButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_timer_detail_enable"), for: .normal)
        view.setImage(UIImage(named: "btn_timer_detail_disable"), for: .disabled)
        return view
    }()

    let indexLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(12.adjust())
        view.textColor = Constants.Color.silver
        view.textAlignment = .center
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
        
        contentView.addAutolayoutSubviews([optionButton, containerView, indexLabel])
        optionButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(containerView.snp.top)
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(30.adjust())
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
    
    // MARK: - bind
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
    private func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        
        // Set badge color
        containerView.backgroundColor = isSelected ? (isEnabled ? Constants.Color.codGray : Constants.Color.gallery) : Constants.Color.white
        
        // Set time label color
        timeLabel.textColor = isEnabled ? (isSelected ? Constants.Color.white : Constants.Color.codGray) : Constants.Color.silver
        
        // Set index label color
        indexLabel.textColor = isEnabled ? Constants.Color.codGray : Constants.Color.silver
        
        // Set option button enabled
        optionButton.isEnabled = isEnabled
    }
    
    private func setSelected(_ isSelected: Bool) {
        self.isSelected = isSelected
        
        // Set badge color
        containerView.backgroundColor = isSelected ? (isEnabled ? Constants.Color.codGray : Constants.Color.gallery) : Constants.Color.white
        containerView.layer.borderColor = isSelected ? Constants.Color.clear.cgColor : Constants.Color.gallery.cgColor
        
        // Set time label color
        timeLabel.textColor = isEnabled ? (isSelected ? Constants.Color.white : Constants.Color.codGray) : Constants.Color.silver
        
        // Set index label color
        indexLabel.textColor = isEnabled ? Constants.Color.codGray : Constants.Color.silver
        
        // Set option button visible
        optionButton.isHidden = !isSelected
    }
}
