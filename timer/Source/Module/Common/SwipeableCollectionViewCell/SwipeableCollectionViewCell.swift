//
//  SwipeableCollectionViewCell.swift
//  timer
//
//  Created by JSilver on 2020/04/15.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

import UIKit

class SwipeableCollectionViewCell: UICollectionViewCell {
    // MARK: - constants
    private static let SWIPE_THRESHOLD_WEIGHT: CGFloat = 0.1
    private static let SWIPE_VELOCITY_THRESHOLD: CGFloat = 500
    
    enum Direction {
        case left
        case right
    }
    
    // MARK: - view property
    let leftActionView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    let rightActionView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private weak var collectionView: UICollectionView?
    
    // MARK: - property
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var resetAnimator: UIViewPropertyAnimator?
    
    private var origin: CGPoint = .zero
    private(set) var direction: Direction? {
        didSet {
            leftActionView.isHidden = direction != .right
            rightActionView.isHidden = direction != .left
        }
    }
    
    /// Swipe animation speed (seconds). default is `0.3` seconds
    var speed: Double = 0.3
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // Find collection view among parent view hierarchy
        var view: UIView = self
        while let superview = view.superview {
            view = superview
            
            if let collectionView = view as? UICollectionView {
                setUp(collectionView: collectionView)
                return
            }
        }
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superview = superview else { return false }
        
        let point = convert(point, to: superview)
        
        for cell in collectionView?.swipeCells ?? [] {
            if !cell.frame.contains(point) {
                // Reset other swiped cells
                cell.reset(animated: true)
            }
        }
        
        return frame.contains(point)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard contentView.frame.origin != .zero else {
            super.touchesEnded(touches, with: event)
            return
        }
        
        // Reset if content view dosen't positioned zero
        reset(animated: true)
    }
    
    // MARK: - private method
    private func setUpLayout() {
        insertSubview(leftActionView, belowSubview: contentView)
        leftActionView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }
        
        insertSubview(rightActionView, belowSubview: contentView)
        rightActionView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
        }
        
        // Create pan gesture recognizer to swipe
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        panGestureRecognizer.delegate = self
        // Add pan gesture to content view
        contentView.addGestureRecognizer(panGestureRecognizer)
        
        self.panGestureRecognizer = panGestureRecognizer
    }
    
    private func setUp(collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        // Add action handler to collection view's pan gesture
        collectionView.panGestureRecognizer.removeTarget(self, action: nil)
        collectionView.panGestureRecognizer.addTarget(self, action: #selector(handleCollectionPan(gesture:)))
    }
    
    private func reset(animated: Bool) {
        let resetOrigin = {
            self.contentView.frame.origin = .zero
        }
        
        if animated {
            guard resetAnimator == nil else { return }
            
            resetAnimator = UIViewPropertyAnimator(duration: speed, curve: .linear) {
                resetOrigin()
            }
            resetAnimator?.addCompletion({
                self.resetAnimator = nil
                if $0 == .end {
                    self.direction = nil
                }
            })
            
            resetAnimator?.startAnimation()
            
        } else {
            resetOrigin()
            direction = nil
        }
    }
    
    // MARK: - selector
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            // Save origin point of content view
            origin = contentView.frame.origin
            if origin == .zero {
                // Initialize direction if content view positioned .zero
                direction = nil
            }
            
        case .changed:
            // Get pan translation
            let translation = gesture.translation(in: contentView)
            if direction == nil {
                // Set swipe direction once
                direction = translation.x > 0 ? .right : .left
            }
            
            // Adjust content view frame
            var point = origin.x + translation.x
            switch direction {
            case .left:
                let width = rightActionView.bounds.width
                if point < -width {
                    point = -(width + max(abs(point) - width, 0) * Self.SWIPE_THRESHOLD_WEIGHT)
                } else if point > 0 {
                    point *= Self.SWIPE_THRESHOLD_WEIGHT
                }
                
            case .right:
                let width = leftActionView.bounds.width
                if point > width {
                    point = width + max(abs(point) - width, 0) * Self.SWIPE_THRESHOLD_WEIGHT
                } else if point < 0 {
                    point *= Self.SWIPE_THRESHOLD_WEIGHT
                }
                
            default:
                return
            }
            
            // Move content view
            self.contentView.frame.origin.x = point
            
        case .ended:
            // Get pan translation & velocity
            let translation = gesture.translation(in: contentView)
            let velocity = gesture.velocity(in: contentView)
            
            // Adjust content view frame
            var point: CGFloat = 0
            switch self.direction {
            case .left:
                let width = self.rightActionView.bounds.width
                if velocity.x < -Self.SWIPE_VELOCITY_THRESHOLD || translation.x < -width / 2 {
                    point = -width
                }
                
            case .right:
                let width = self.leftActionView.bounds.width
                if velocity.x > Self.SWIPE_VELOCITY_THRESHOLD || translation.x > width / 2 {
                    point = width
                }
                
            default:
                return
            }
            
            // Animate content view set origin
            UIView.animate(withDuration: speed, delay: 0, options: .allowUserInteraction, animations: {
                self.contentView.frame.origin.x = point
            }, completion: {
                if $0 && point == 0 {
                    self.direction = nil
                }
            })
            
        default:
            break
        }
    }
    
    @objc private func handleCollectionPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            // Reset cell position when collection view pan gesture began
            reset(animated: true)
        }
    }
}

extension SwipeableCollectionViewCell: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let view = gestureRecognizer.view, gestureRecognizer == panGestureRecognizer {
            guard let translation = panGestureRecognizer?.translation(in: view) else { return true }
            return abs(translation.y) <= abs(translation.x)
        }
        
        return true
    }
}
