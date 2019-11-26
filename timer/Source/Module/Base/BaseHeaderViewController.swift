//
//  BaseHeaderViewController.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/// - warning: Shouldn't use `Base` controller not inherited
class BaseHeaderViewController: BaseViewController {
    var headerView: Header { return Header() }
    
    override func bind() {
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
    }

    func handleHeaderAction(_ action: Header.Action) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Implement default header action
        switch action {
        case .back,
             .cancel,
             .close:
            dismissOrPopViewController(animated: true)
            
        default:
            break
        }
    }
}

extension BaseHeaderViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetThreshold: CGFloat = 3
        let blurThreshold: CGFloat = 10
        let weight: CGFloat = 5

        // Set shadow by scroll
        headerView.layer.shadow(alpha: 0.04,
                                offset: CGSize(width: 0, height: min(scrollView.contentOffset.y / weight, offsetThreshold)),
                                blur: min(scrollView.contentOffset.y / weight, blurThreshold))
    }
}

extension Reactive where Base: BaseHeaderViewController {
    var tapHeader: ControlEvent<Header.Action> {
        return ControlEvent(events: base.headerView.rx.tap)
    }
}
