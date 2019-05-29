//
//  ProductivityTimerCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 07/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class ProductivityTimerCollectionViewCell: UICollectionViewCell, View {
    static let ReuseableIdentifier = "ProductivityTimerCollectionViewCell"
    
    // MARK: - view properties
    let timeLabel: UILabel = {
        let view = UILabel()
        view.text = ""
        view.textColor = Constants.Color.white
        view.font = Constants.Font.ExtraBold.withSize(12.adjust())
        view.textAlignment = .center
        return view
    }()
    
    private lazy var containerView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = Constants.Color.black

        // Set constarint of subviews
        view.addAutolayoutSubview(self.timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 5.adjust(), left: 10.adjust(), bottom: 5.adjust(), right: 10.adjust()))
        }

        return view
    }()

    private let optionButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "timer_more_btn"), for: .normal)
        view.contentVerticalAlignment = .bottom
        return view
    }()

    private let indexLabel: UILabel = {
        let view = UILabel()
        view.text = "1"
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
            make.height.equalTo(13.adjust())
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(24.adjust())
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
    
    // MARK: - reactor bind
    func bind(reactor: ProductivityTimerCollectionViewCellReactor) {
        // MARK: action
        
        // MARK: state
        reactor.state
            .map { Int($0.time) }
            .map {
                let seconds = $0 % 60
                let minutes = ($0 / 60) % 60
                let hours = $0 / 3600
                
                return String.init(format: "%03d:%02d:%02d", hours, minutes, seconds)
            }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { String($0.index) }
            .bind(to: indexLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selected }
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.setSelected($0)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { !$0.selected }
            .bind(to: optionButton.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func setSelected(_ isSelected: Bool) {
        containerView.backgroundColor = isSelected ? Constants.Color.black : Constants.Color.clear
        timeLabel.textColor = isSelected ? Constants.Color.white : Constants.Color.black
    }
}
