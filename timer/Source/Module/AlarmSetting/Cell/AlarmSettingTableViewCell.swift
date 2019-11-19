//
//  AlarmSettingTableViewCell.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class AlarmSettingTableViewCell: UITableViewCell, ReactorKit.View {
    // MARK: - view properties
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let playButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_play"), for: .normal)
        view.setImage(UIImage(named: "btn_pause"), for: .selected)
        return view
    }()
    
    private let selectIconImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon_selected"))
        return view
    }()
    
    // MARK: - properties
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Constants.Color.clear
        selectionStyle = .none
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.silver
        
        // Set constraint of subviews
        addAutolayoutSubviews([playButton, titleLabel, selectIconImageView, divider])
        playButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.2.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(selectIconImageView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(playButton.snp.trailing).inset(-3.5.adjust())
            make.trailing.equalTo(selectIconImageView.snp.leading)
            make.centerY.equalToSuperview()
        }
        
        selectIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.8.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(selectIconImageView.snp.width)
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.8.adjust())
            make.trailing.equalToSuperview().inset(20.8.adjust())
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    func bind(reactor: AlarmSettingTableViewCellReactor) {
        // MARK: action
        // MARK: state
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.alarmState }
            .distinctUntilChanged()
            .compactMap { [weak self] in self?.setPlayButtonState(from: $0) }
            .bind(to: playButton.rx.isSelected)
            .disposed(by: disposeBag)
    }
    
    // MARK: - state method
    private func setPlayButtonState(from alarmState: AlarmSettingTableViewCellReactor.AlarmState) -> Bool {
        switch alarmState {
        case .play:
            return true
            
        case .stop:
            return false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        selectIconImageView.isHidden = !selected
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct AlarmSettingTableViewCellPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> AlarmSettingTableViewCell {
        return AlarmSettingTableViewCell()
    }
    
    func updateUIView(_ uiView: AlarmSettingTableViewCell, context: Context) {
        // Nothing
        uiView.titleLabel.text = "기본음"
    }
}

struct Previews_AlarmSettingTableViewCellView: PreviewProvider {
    static var previews: some SwiftUI.View {
        Group {
            AlarmSettingTableViewCellPreview()
                .frame(height: 80)
                .previewLayout(.sizeThatFits)
        }
    }
}

#endif
