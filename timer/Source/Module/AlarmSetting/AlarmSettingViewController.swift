//
//  AlarmSettingViewController.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources
import AVFoundation

class AlarmSettingViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - view properties
    private var alarmSettingView: AlarmSettingView { return view as! AlarmSettingView }
    
    override var headerView: CommonHeader { return alarmSettingView.headerView }
    
    private var alarmSettingTableView: UITableView { return alarmSettingView.alarmTableView }
    
    // MARK: - properties
    var coordinator: AlarmSettingViewCoordinator
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<AlarmSettingSectionModel>(configureCell: { [weak self] (datasource, tableView, indexPath, item) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmSettingTableViewCell.name, for: indexPath) as? AlarmSettingTableViewCell else { return UITableViewCell() }
        
        // Stong capture `self`
        guard let reactor = self?.reactor else { return cell }
        cell.reactor = item
        
        switch item.alarm {
        case .default:
            cell.playButton.isHidden = false
            
            cell.playButton.rx.tap
                .withLatestFrom(reactor.state.map { $0.playIndex })
                .compactMap { self?.playButtonTapped(alarm: item.alarm, at: indexPath.item, currentIndex: $0) }
                .bind(to: reactor.action)
                .disposed(by: cell.disposeBag)
            
        default:
            cell.playButton.isHidden = true
        }
        
        return cell
    })
    
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - constructor
    init(coordinator: AlarmSettingViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = AlarmSettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell
        alarmSettingTableView.register(AlarmSettingTableViewCell.self, forCellReuseIdentifier: AlarmSettingTableViewCell.name)
    }
    
    // MARK: - bine
    override func bind() {
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
        
        alarmSettingTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: AlarmSettingViewReactor) {
        // MARK: action
        rx.viewDidLoad
            .map { Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        alarmSettingTableView.rx.itemSelected
            .map { Reactor.Action.select($0.item) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .bind(to: alarmSettingTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedIndex }
            .distinctUntilChanged()
            .map { IndexPath(item: $0, section: 0) }
            .subscribe(onNext: { [weak self] in self?.alarmSettingTableView.selectRow(at: $0, animated: true, scrollPosition: .none) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    /// Handle header button tap action according to button type
    func handleHeaderAction(_ action: Header.Action) {
        switch action {
        case .back:
            coordinator.present(for: .dismiss)
            
        default:
            break
        }
    }
    
    // MARK: - private method
    private func playButtonTapped(alarm: Alarm, at index: Int, currentIndex: Int?) -> AlarmSettingViewReactor.Action {
        if currentIndex == index && audioPlayer?.isPlaying ?? false {
            // Playing alarm
            stop()
            return .stop
        } else {
            // No alarm is playing
            play(alarm: alarm)
            return .play(index)
        }
    }
    
    private func play(alarm: Alarm) {
        guard let fileName = Alarm.default.getFileName(type: .short),
            let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        
        // Alert alarm
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        // Play alarm
        audioPlayer?.play()
    }
    
    private func pause() {
        // Pause alarm
        audioPlayer?.pause()
    }
    
    private func stop() {
        // Stop alarm
        audioPlayer?.stop()
    }
    
    deinit {
        Logger.verbose()
    }
}

extension AlarmSettingViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Stop played alarm
        reactor?.action.onNext(.stop)
    }
}

// MARK: - alarm setting datasource
typealias AlarmSettingSectionModel = SectionModel<Void, AlarmSettingTableViewCellReactor>
