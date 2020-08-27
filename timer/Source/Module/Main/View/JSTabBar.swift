//
//  JSTabBar.swift
//  timer
//
//  Created by JSilver on 29/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol JSTabBarDelegate: class {
    func tabBar(_ tabBar: JSTabBar, didSelect index: Int)
}

class JSTabBar: UIView {
    // MARK: - constants
    private static let ANIMATION_DURATION: TimeInterval = 0.3
    
    // MARK: - view properties
    private lazy var tabBarStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: tabBarItems)
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = R.Color.silver
        return view
    }()
    
    private let indicatorView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 2))
        return view
    }()
    
    // MARK: - properties
    var tabBarItems: [JSTabBarItem] = [] {
        didSet {
            // Remove all added tab bar items
            tabBarStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            // Add all tab bar items
            tabBarItems.enumerated().forEach { index, element in
                tabBarStackView.addArrangedSubview(element)
                
                // Set default properties of tab bar item
                element.tag = index
                element.tintColor = tintColor
                element.title.font = font
                
                // Add touch event
                element.addTarget(self, action: #selector(tabBarItemSelect(sender:)), for: .touchUpInside)
            }
        }
    }
    // Observe tint color did changed to update background color of indicator view
    override var tintColor: UIColor! {
        didSet {
            tabBarItems.forEach { $0.tintColor = tintColor }
            indicatorView.backgroundColor = tintColor
        }
    }
    // Observe font did changed to update font of title of tab bar item
    var font: UIFont = UIFont.systemFont(ofSize: 17.0) {
        didSet { tabBarItems.forEach { $0.title.font = font } }
    }
    
    var isIconHighlight: Bool = true {
        didSet { select(at: selectedIndex) }
    }
    
    // Indicator animator
    private var lastAnimator: UIViewPropertyAnimator?
    private var selectedIndex: Int = 0
    
    weak var delegate: JSTabBarDelegate?
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = R.Color.white_fdfdfd
        
        addAutolayoutSubviews([tabBarStackView, dividerView, indicatorView])
        tabBarStackView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
            make.height.equalTo(60.5.adjust())
        }
        
        dividerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func draw(_ rect: CGRect) {
        // Calculate indicator view width accourding to tab bar item's count
        let width = frame.width / CGFloat(tabBarItems.count)
        
        indicatorView.frame.size.width = width
        indicatorView.frame.origin.x = width * CGFloat(selectedIndex)
    }
    
    // MARK: - private method
    private func select(at index: Int) {
        guard (0 ..< tabBarItems.count).contains(index) else { return }
        if isIconHighlight {
            // De & select tab bar item if `isIconHighlight` is `true`
            tabBarItems[selectedIndex].isSelected = false
            tabBarItems[index].isSelected = true
        }
        
        selectedIndex = index
    }
    
    // MARK: - public method
    // FIXME: Animation issue
    /// # Known issue
    /// If you use this method for gesture interaction like pan swipe, indicator view isn't work well a specific case.
    ///
    /// It is occur during swipe after first swipe cancel (reverse animation).
    ///
    /// ## Case 1. Same direction
    /// Indicator view's position is target position already when first swipe canceled.
    /// Thus second swipe animation is ignored because there is no differece of `frame`.
    ///
    /// ## Case 2. Otherside direction
    /// Indicator animation isn't work too. but i couldn't figure out the cause.
    ///
    /// ## Conclusion
    /// For now, I set animation duration short enough to make impossible to cancel interaction.
    @discardableResult
    func select(at index: Int, animated: Bool) -> UIViewPropertyAnimator? {
        guard (0 ..< tabBarItems.count).contains(index) else { return nil }
        
        // Get indicator view frame
        let frame = indicatorView.frame
        let toPosition = frame.width * CGFloat(index)
        
        if animated {
            if let animator = lastAnimator {
                // Stop animator if last animator is running still
                animator.stopAnimation(true)
            }
            
            let animator = UIViewPropertyAnimator(
                duration: Self.ANIMATION_DURATION,
                controlPoint1: CGPoint(x: 0.65, y: 0.0),
                controlPoint2: CGPoint(x: 0.35, y: 1.0)
            ) {
                self.indicatorView.frame.origin.x = toPosition
            }
            
            animator.addCompletion { position in
                if animator == self.lastAnimator && position == .end {
                    // If a completed animator is the last requested animator, set the icon highlight
                    self.lastAnimator = nil
                    self.select(at: index)
                }
            }
            
            animator.startAnimation()
            lastAnimator = animator // Update the last animator per request
            
            return animator
        } else {
            // If non animated, indicator move & icon highlight
            indicatorView.frame.origin.x = toPosition
            select(at: index)
            
            return nil
        }
    }
    
    // MARK: - selector
    @objc private func tabBarItemSelect(sender: UIButton) {
        delegate?.tabBar(self, didSelect: sender.tag)
    }
}
