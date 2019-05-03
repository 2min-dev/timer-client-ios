//
//  TimerSetTableViewCell.swift
//  timer
//
//  Created by JSilver on 02/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class TimerSetTableViewCell: UITableViewCell, View {
    // MARK: - view properties
    private let nameLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private let countLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var titleStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.nameLabel, self.countLabel])
        view.axis = .horizontal
        view.alignment = UIStackView.Alignment.leading
        view.spacing = 10.adjust()
        return view
    }()
    
    private let timerLabel: UILabel = {
        let view = UILabel()
        view.text = "99:99:99"
        return view
    }()
    
    private lazy var contentStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.titleStackView, self.timerLabel])
        view.axis = .vertical
        view.alignment = .leading
        return view
    }()
    
    private let stateButton: UIButton = {
        let view = UIButton()
        return view
    }()
    
    private lazy var stackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.contentStackView, self.stateButton])
        view.axis = .horizontal
        view.alignment = UIStackView.Alignment.center
        return view
    }()
    
    // MARK: - properties
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setSubviewForAutoLayout(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20.adjust(), bottom: 0, right: 0))
        }
        
        stateButton.snp.makeConstraints { make in
            make.width.equalTo(60.adjust())
            make.height.equalTo(stateButton.snp.width)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - reactor bind
    func bind(reactor: TimerSetTableViewCellReactor) {
        // MARK: action
        stateButton.rx.tap
            .map { Reactor.Action.touchStateButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .map { $0.name }
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { String($0.count) }
            .bind(to: countLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { String($0.state.rawValue) }
            .subscribe(onNext: {
                self.stateButton.setAttributedTitle(NSAttributedString(string: $0, attributes: [
                    .foregroundColor: Constants.Color.gray
                    ]), for: .normal)
                self.stateButton.setTitle($0, for: .normal)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { !$0.stateChanging }
            .distinctUntilChanged()
            .bind(to: stateButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
