//
//  SideTimerTableViewCell.swift
//  timer
//
//  Created by JSilver on 07/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class SideTimerTableViewCell: UITableViewCell, View {
    // MARK: - view properties
    let timeLabel: UILabel = {
        let view = UILabel()
        view.textColor = Constants.Color.white
        view.font = Constants.Font.NanumSquareRoundR.withSize(12.adjust())
        return view
    }()
    
    private lazy var containerView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = Constants.Color.black
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
        view.setSubviewForAutoLayout(self.timeLabel)
        return view
    }()
    
    // MARK: - properties
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = Constants.Color.clear
        
        setSubviewForAutoLayout(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5.adjust())
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(5.adjust())
            make.height.equalTo(28).priority(999) // To solve autolayout warning
        }
        
        timeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 5))
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        timeLabel.textColor = selected ? Constants.Color.white : Constants.Color.black
        containerView.backgroundColor = selected ? Constants.Color.black : Constants.Color.lightGray
    }
    
    // MARK: - reactor bind
    func bind(reactor: SideTimerTableViewCellReactor) {
        // MARK: action
        
        // MARK: state
        reactor.state
            .map { $0.time }
            .map { getDateString(format: "HH MM ss", date: Date(timeIntervalSince1970: $0)) }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        Logger.debug()
    }
}
