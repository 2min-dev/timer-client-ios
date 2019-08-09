//
//  MainViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift

class MainViewController: UITabBarController {
    // MARK: - constants
    enum TabType: Int {
        case LocalTimeSet = 0
        case Productivity
        case SharedTimeSet
    }
    
    // MARK: - view properties
    let _tabBar: TMTabBar = {
        let view = TMTabBar()
        view.tintColor = Constants.Color.carnation
        view.font = Constants.Font.Regular.withSize(12.adjust())
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
    var disposeBag = DisposeBag()
    
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
        view.backgroundColor = Constants.Color.white
        tabBar.isHidden = true
        
        view.addAutolayoutSubview(_tabBar)
        _tabBar.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // Set tab bar items
        _tabBar.tabBarItems = [
            TMTabBarItem(title: "tab_button_my_time_set".localized, icon: UIImage(named: "btn_tab_my")),
            TMTabBarItem(title: "tab_button_home".localized, icon: UIImage(named: "btn_tab_home")),
            TMTabBarItem(title: "tab_button_shared_time_set".localized, icon: UIImage(named: "btn_tab_share"))
        ]
        
        // Set view controllers
        viewControllers = [coordinator.get(for: .local), coordinator.get(for: .productivity), coordinator.get(for: .share)].compactMap { $0 }
        
        // Set tab bar view controller delegate for swipable
        delegate = self
        _tabBar.delegate = self
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureHandler(gesture:)))
        panGestureRecognizer.delegate = self
        
        view.addGestureRecognizer(panGestureRecognizer)
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

// TODO: ?? not used maybe
extension MainViewController: UIGestureRecognizerDelegate {
    // Return gesture recognizer interpert touch event only tab view controller is single
    // * non single view like navigation controller or etc *
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let currentViewController = selectedViewController as? UINavigationController else { return true }
        return currentViewController.viewControllers.count > 1 ? false : true
    }
}
