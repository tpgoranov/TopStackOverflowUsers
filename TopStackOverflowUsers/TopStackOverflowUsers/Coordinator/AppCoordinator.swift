//
//  AppCoordinator.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 28/04/2026.
//

import UIKit

protocol Coordinator {
    func start()
}

@MainActor
final class AppCoordinator {
    private var navigationController: UINavigationController
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let topUsersViewController = storyboard.instantiateInitialViewController() as? TopUsersTableViewController else {
            return
        }
        navigationController.setViewControllers([topUsersViewController], animated: false)
    }
}





