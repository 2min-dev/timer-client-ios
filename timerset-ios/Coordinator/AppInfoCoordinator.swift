//
//  AppInfoCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

enum AppInfoRoute {

}

class AppInfoCoordinator {
	// MARK: properties
	var rootViewController: AppInfoViewController
	let provider: ServiceProviderProtocol

	init(provider: ServiceProviderProtocol) {
		self.rootViewController = AppInfoViewController()
		self.provider = provider

		// DI
		self.rootViewController.coordinator = self
		self.rootViewController.reactor = AppInfoViewReactor()
	}

	func present(for route: AppInfoRoute) {

	}
} 
