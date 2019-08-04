//
//  TMTabBar.swift
//  timer
//
//  Created by JSilver on 29/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol TMTabBarDelegate: class {
    func tabBar(_ tabBar: TMTabBar, didSelect index: Int)
}

class TMTabBar: UIView {
    // MARK: - view properties
    private lazy var tabBarStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: tabBarItems)
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.lightGray
        return view
    }()
    
    private let indicatorView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 2))
        view.backgroundColor = UIColor(hex: "#007AFF")
        return view
    }()
    
    // MARK: - properties
    var tabBarItems: [TMTabBarItem] = [] {
        didSet {
            // Remove all added tab bar items
            tabBarStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            // Add all tab bar items
            tabBarItems.enumerated().forEach { index, element in
                tabBarStackView.addArrangedSubview(element)
                
                // Set default properties of tab bar item
                element.tag = index
                element.title.font = font
                
                // Add touch event
                element.addTarget(self, action: #selector(tabBarItemSelect(sender:)), for: .touchUpInside)
            }
        }
    }
    // Observe tint color did changed to update background color of indicator view
    override var tintColor: UIColor! {
        didSet { indicatorView.backgroundColor = tintColor }
    }
    // Observe font did changed to update font of title of tab bar item
    var font: UIFont! {
        didSet { tabBarItems.forEach { $0.title.font = font } }
    }
    var isIconHighlight: Bool = true
    
    // Indicator animation & icon highlighting properties
    private var lastAnimator: UIViewPropertyAnimator?
    var selectedItem: TMTabBarItem?
    
    weak var delegate: TMTabBarDelegate?
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "#FDFDFD")
        
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
    
    override func layoutSubviews() {
        // Calculate indicator view width accourding to tab bar item's count
        indicatorView.frame.size.width = frame.width / CGFloat(tabBarItems.count)
        
        if let item = selectedItem, let index = tabBarItems.firstIndex(of: item) {
            // Select tab if need to reselect current tab
            _ = select(at: index, animated: false)
        }
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
    func select(at index: Int, animated: Bool) -> UIViewPropertyAnimator? {
        guard index < tabBarItems.count else { return nil }
        let item = tabBarItems[index]
        
        var frame = indicatorView.frame
        frame.origin.x = frame.width * CGFloat(index)
        
        if animated {
            let animator = UIViewPropertyAnimator(duration: 0.3,
                                                  controlPoint1: CGPoint(x: 0.65, y: 0.0),
                                                  controlPoint2: CGPoint(x: 0.35, y: 1.0)) {
                self.indicatorView.frame = frame
            }
            
            animator.addCompletion({ position in
                if animator == self.lastAnimator && self.isIconHighlight && position == .end {
                    // If a completed animator is the last requested animator, set the icon highlight
                    self.lastAnimator = nil
                    self.select(item: item)
                }
            })
            
            animator.startAnimation()
            lastAnimator = animator // Update the last animator per request
            return animator
        } else {
            // If non animated, indicator move & icon highlight
            indicatorView.frame = frame
            select(item: item)
            
            return nil
        }
    }
    
    // MARK: - private method
    private func select(item: TMTabBarItem) {
        selectedItem?.isSelected = false
        selectedItem = item
        selectedItem?.isSelected = true
    }
    
    // MARK: - selector
    @objc private func tabBarItemSelect(sender: UIButton) {
        _ = select(at: sender.tag, animated: true)
        delegate?.tabBar(self, didSelect: sender.tag)
    }
}
