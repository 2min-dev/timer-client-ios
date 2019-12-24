//
//  MainViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class MainViewController: UITabBarController, ViewControllable, View {
    // MARK: - constants
    enum TabType: Int {
        case localTimeSet = 0
        case productivity
        case preset
    }
    
    // MARK: - view properties
    let _tabBar: TMTabBar = {
        let view = TMTabBar()
        view.tabBarItems = [
            TMTabBarItem(title: "tab_button_my_time_set".localized, icon: UIImage(named: "btn_tab_my")),
            TMTabBarItem(title: "tab_button_home".localized, icon: UIImage(named: "btn_tab_home")),
            TMTabBarItem(title: "tab_button_preset".localized, icon: UIImage(named: "btn_tab_share"))
        ]
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.tintColor = Constants.Color.carnation
        return view
    }()
    
    // MARK: - properties
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var panGestureDirection: UIRectEdge?
    
    // Enable/Disable swipes on the tab bar controller
    var swipeEnable = true {
        didSet { panGestureRecognizer.isEnabled = swipeEnable }
    }
    
    var coordinator: MainViewCoordinator
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - constructor
    init(coordinator: MainViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
        
        // Set view controllers
        viewControllers = [coordinator.get(for: .local),
                           coordinator.get(for: .productivity),
                           coordinator.get(for: .preset)]
            .compactMap { $0?.controller }
        
        // Set tab bar view controller delegate for swipable
        delegate = self
        _tabBar.delegate = self
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureHandler(gesture:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            // Nothing newer than iOS 11.0
        } else {
            // Invalidate current layout to update child view controller's view size
            view.setNeedsLayout()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update child view controller view size
        viewControllers?.forEach {
            if #available(iOS 11.0, *) {
                // Set child viewcontrollers sefaarea
                $0.additionalSafeAreaInsets.bottom = self._tabBar.bounds.height - self.view.safeAreaInsets.bottom
            } else {
                $0.view.frame.size.height = self.view.bounds.height - self._tabBar.bounds.height
            }
        }
    }
    
    // MARK: - bind
    func bind(reactor: MainViewReactor) {
        // MARK: action
        
        // MARK: state
        reactor.state
            .map { $0.previousHistory }
            .distinctUntilChanged()
            .compactMap { $0.value }
            .subscribe(onNext: { [weak self] in self?.showTimeSetEndToast(history: $0) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    // MARK: - state method
    private func showTimeSetEndToast(history: History) {
        switch history.endState {
        case .cancel:
            Toast(
                content: "toast_time_set_end_cancel_title".localized,
                task: ToastTask(title: "toast_task_move_title".localized, handler: {
                    _ = self.coordinator.present(for: .historyDetail(history), animated: true)
                })
            ).show(animated: true, withDuration: 3)
            
        case .overtime:
            Toast(
                content: "toast_time_set_end_overtime_title".localized,
                task: ToastTask(title: "toast_task_memo_title".localized, handler: {
                    _ = self.coordinator.present(for: .historyDetail(history), animated: true)
                })
            ).show(animated: true, withDuration: 3)
            
        default:
            break
        }
    }
    
    // MARK: - private method
    private func initLayout() {
        view.backgroundColor = Constants.Color.white
        tabBar.isHidden = true
        
        // Set constraints of subviews
        view.addAutolayoutSubview(_tabBar)
        _tabBar.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - public method
    func select(at index: Int, animated: Bool) {
        selectedIndex = index
        _ = _tabBar.select(at: index, animated: animated)
    }
    
    // MARK: - selector
    @objc private func gestureHandler(gesture: UIPanGestureRecognizer) {
        // Do not attempt to begin an interactive transition if one is already
        guard transitionCoordinator == nil else { return }
        
        if gesture.state == .began || gesture.state == .changed {
            let translation = gesture.translation(in: view)
            if translation.x > 0.0 && selectedIndex > 0 {
                // Panning right, transition to the left view controller.
                panGestureDirection = .left
                selectedIndex -= 1
            } else if translation.x < 0.0 && selectedIndex + 1 < viewControllers?.count ?? 0 {
                // Panning left, transition to the right view controller.
                panGestureDirection = .right
                selectedIndex += 1
            }
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - extension
extension MainViewController: UITabBarControllerDelegate {
    // Return animator of transitioning when tab changed
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let fromIndex = tabBarController.viewControllers?.firstIndex(of: fromVC),
            let toIndex = tabBarController.viewControllers?.firstIndex(of: toVC) else { return nil }
        
        return TabBarAnimator(tabBarController: self, at: fromIndex, to: toIndex)
    }
    
    // Return interactor of transitioning animator when tab changed
    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let tabBarController = tabBarController as? MainViewController,
            let animationController = animationController as? TabBarAnimator else { return nil }

        // Return interactor only change selected tab by pan gesture
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            // Get animator to use for interaction
            guard let animator = tabBarController._tabBar.select(at: animationController.toIndex, animated: true) else { return nil }
            animator.pauseAnimation() // Pause animator to control through `fractionComplete`
            
            return TabBarInteractor(animator: animator,
                                    gestureRecognizer: panGestureRecognizer,
                                    direction: panGestureDirection ?? .top)
        } else {
            return nil
        }
    }
}

extension MainViewController: TMTabBarDelegate {
    func tabBar(_ tabBar: TMTabBar, didSelect index: Int) {
        selectedViewController = viewControllers?[index]
    }
}
