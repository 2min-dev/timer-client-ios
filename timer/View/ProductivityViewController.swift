//
//  ProductivityViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class ProductivityViewController: BaseViewController, View {
    // MARK: - view properties
    private var productivityView: ProductivityView { return self.view as! ProductivityView }
    private var contentView: UIView { return productivityView.contentView }
    
    private var footerStackView: UIStackView { return productivityView.footerStackView }
    private var footerView: UIView { return productivityView.footerView }
    
    private var timerLabel: UILabel { return productivityView.timerLabel }
    private var timerInputLabel: UILabel { return productivityView.timerInputLabel }
    
    private var keyPadView: KeyPad { return productivityView.keyPadView }
    
    private var sideTimerTableView: UITableView { return productivityView.sideTimerTableView }
    
    private var saveButton: UIButton { return productivityView.saveButton }
    private var addButton: UIButton { return productivityView.addButton }
    
    // MARK: - properties
    var coordinator: ProductivityViewCoordinator!

    private let datasource = RxTableViewSectionedReloadDataSource<SideTimerListSection>(configureCell: { datasource, tableView, indexPath, item in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SideTimerTableViewCell", for: indexPath) as? SideTimerTableViewCell else {
            fatalError("Table view cell isn't SideTimerTableViewCell")
        }
        cell.reactor = item
        return cell
    })
    
    // MARK: - lifecycle
    override func loadView() {
        self.view = ProductivityView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideTimerTableView.register(SideTimerTableViewCell.self, forCellReuseIdentifier: "SideTimerTableViewCell")
    }
    
    // MARK: - reactor bind
    func bind(reactor: ProductivityViewReactor) {
        // MARK: action
        keyPadView.rx.keyPadTap
            .filter(isValidKey)
            .map(makeTimeWithKey)
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
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.coordinator.present(for: .createTimerSet(reactor.timerSet))
            })
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .map { Reactor.Action.addTimer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        sideTimerTableView.rx.itemSelected
            .map { Reactor.Action.timerSelected($0) }
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
                guard $0 > 0 else { return "0" }
                
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .full
                formatter.allowedUnits = [.hour, .minute, .second]
                return formatter.string(from: $0) ?? ""
            }
            .bind(to: timerLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.shouldReloadSection }
            .map { $0.sections }
            .bind(to: sideTimerTableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    private func isValidKey(_ key: KeyPad.Key) -> Bool {
        guard key != .cancel else { return false }
        guard let text = self.timerInputLabel.text else { return false }
        
        switch key {
        case .back:
            return !text.isEmpty
        default:
            return text.count < 3
        }
    }
    
    private func makeTimeWithKey(_ key: KeyPad.Key) -> Int {
        guard var text = self.timerInputLabel.text else { return 0 }
        
        switch key {
        case .back:
            text.removeLast()
        default:
            text.append(String(key.rawValue))
        }
        
        return Int(text) ?? 0
    }
    
    deinit {
        Logger.verbose()
    }
}
