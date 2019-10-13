//
//  NoticeListViewCoordinator.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class NoticeListViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum Route {
        case noticeDetail(Notice)
    }
    
    // MARK: - properties
    weak var viewController: UIViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: Route) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .noticeDetail(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case let .noticeDetail(notice):
            let coordinator = NoticeDetailViewCoordinator(provider: provider)
            let reactor = NoticeDetailViewReactor(notice: notice)
            let viewController = NoticeDetailViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
    
    // MARK: - private method
    // MARK: - public method
}
