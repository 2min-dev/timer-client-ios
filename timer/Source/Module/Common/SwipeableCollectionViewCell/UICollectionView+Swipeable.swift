//
//  UICollectionView+Swipeable.swift
//  timer
//
//  Created by JSilver on 2020/04/15.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

import UIKit

extension UICollectionView {
    var swipeCells: [SwipeableCollectionViewCell] {
        visibleCells.compactMap { $0 as? SwipeableCollectionViewCell }
            .filter { $0.direction != nil }
    }
}
