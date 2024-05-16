//
//  TabBarController.swift
//  DeliveryApp
//

import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Private properties
    private var categoryCoordinator: CategoryCoordinator?

    private enum Constants {
        static let home = "home"
        static let userIconImage = "person.circle"
        static let searchImage = "magnifyingglass"
        static let cartImage = "cart"
    }

    // MARK: - Public Methods
    func configure(categoryCoordinator: CategoryCoordinator) {
        self.categoryCoordinator = categoryCoordinator
        setupViewControllers()
    }

    // MARK: - Private Methods
    private func setupViewControllers() {
        guard let categoryCoordinator = self.categoryCoordinator else {
            return
        }

        let categoryNavigationController = categoryCoordinator.navigationController
        categoryNavigationController.tabBarItem = UITabBarItem(
            title: L10n.main,
            image: UIImage(named: Constants.home),
            tag: 0
        )
        
        let searchViewController = SearchViewController()
        let searchNavigationController = UINavigationController(rootViewController: searchViewController)
        searchNavigationController.tabBarItem = UITabBarItem(
            title: L10n.search,
            image: UIImage(systemName: Constants.searchImage),
            tag: 1
        )
        
        let cartViewController = CartViewController()
        let cartNavigationController = UINavigationController(rootViewController: cartViewController)
        cartNavigationController.tabBarItem = UITabBarItem(
            title: L10n.cart,
            image: UIImage(systemName: Constants.cartImage),
            tag: 2
        )
        
        let userViewController = UserViewController()
        let userNavigationController = UINavigationController(rootViewController: userViewController)
        userNavigationController.tabBarItem = UITabBarItem(
            title: L10n.account,
            image: UIImage(systemName: Constants.userIconImage),
            tag: 3
        )
        
        self.viewControllers = [
            categoryNavigationController,
            searchNavigationController,
            cartNavigationController,
            userNavigationController
        ]
        categoryCoordinator.start()
    }
}
