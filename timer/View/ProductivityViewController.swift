//
//  ProductivityViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class ProductivityViewController: BaseViewController, View {
    // MARK: - view properties
    private var productivityView: ProductivityView { return self.view as! ProductivityView }
    private var timerLabel: UILabel { return productivityView.timerLabel }
    private var timerInputLabel: UILabel { return productivityView.timerInputLabel }
    private var keyPadView: KeyPadView { return productivityView.keyPadView }
    private var loopCheckBox: CheckBox { return productivityView.loopCheckBox }
    private var vibrationAlertCheckBox: CheckBox { return productivityView.vibrationAlertCheckBox }
    
    // MARK: - properties
    var coordinator: ProductivityViewCoordinator!
    
    // temp
    var timeInterval: Int = 0
    
    // MARK: - lifecycle
    override func loadView() {
        self.view = ProductivityView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - reactor bind
    func bind(reactor: ProductivityViewReactor) {
        // MARK: action
        keyPadView.rx.keyPadTap
            .filter { key in
                guard key != .cancel else { return false }
                guard let text = self.timerInputLabel.text else { return false }
                
                switch key {
                case .back:
                    return !text.isEmpty
                default:
                    return text.count < 3
                }
            }
            .map { key in
                var text = self.timerInputLabel.text!
                
                switch key {
                case .back:
                    text.removeLast()
                default:
                    text.append(String(key.rawValue))
                }
                
                return Int(text) ?? 0
            }
            .map { Reactor.Action.updateTimeInput($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        keyPadView.rx.keyPadTap
            .filter { $0 == .cancel }
            .map { _ in Reactor.Action.clearTimer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        productivityView.rx.timeKeyTap
            .map { Reactor.Action.tapTimeKey($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        loopCheckBox.rx.tap
            .map { Reactor.Action.toggleLoop }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        vibrationAlertCheckBox.rx.tap
            .map { Reactor.Action.toggleVibrationAlert }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .map { $0.time }
            .distinctUntilChanged()
            .map { $0 > 0 ? String($0) : "" }
            .bind(to: timerInputLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.timer }
            .distinctUntilChanged()
            .map {
                guard $0 > 0 else { return "" }
                
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .full
                formatter.allowedUnits = [.hour, .minute, .second]
                return formatter.string(from: $0) ?? ""
            }
            .bind(to: timerLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.loop }
            .distinctUntilChanged()
            .debug()
            .bind(to: loopCheckBox.rx.isChecked)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.vibationAlert }
            .distinctUntilChanged()
            .debug()
            .bind(to: vibrationAlertCheckBox.rx.isChecked)
            .disposed(by: disposeBag)
    }
    
    deinit {
        Logger.verbose("")
    }
}
