//
//  TabBarController.swift
//  TestMVP
//
//  Created by Висент Щепетков on 02.02.2024.
//

import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Private properties
    private var categoryModuleAssembly: CategoryModuleAssemblyProtocol?
    private var dishModuleAssembly: DishModuleAssemblyProtocol?
    private var addDishModuleAssembly: AddDishModuleAssemblyProtocol?

    private enum Constants {
        static let main = "Главная"
        static let account = "Аккаунт"
        static let search = "Поиск"
        static let cart = "Корзина"
        static let home = "home"
        static let userIconImage = "person.circle"
        static let searchImage = "magnifyingglass"
        static let cartImage = "cart"
    }

    // MARK: - Public Methods
    func configure(
        categoryModuleAssembly: CategoryModuleAssemblyProtocol,
        dishModuleAssembly: DishModuleAssemblyProtocol,
        addDishModuleAssembly: AddDishModuleAssemblyProtocol
    ) {
        self.categoryModuleAssembly = categoryModuleAssembly
        self.dishModuleAssembly = dishModuleAssembly
        self.addDishModuleAssembly = addDishModuleAssembly
        setupViewControllers()
    }

    // MARK: - Private Methods
    private func setupViewControllers() {
        guard let categoryModuleAssembly = self.categoryModuleAssembly,
              let dishModuleAssembly = self.dishModuleAssembly,
              let addDishModuleAssembly = self.addDishModuleAssembly else {
            return
        }

        // Категории
        let categoryNavigationController = UINavigationController()
        let categoryRouter = Router(
            navigationController: categoryNavigationController,
            dishModuleAssembly: dishModuleAssembly,
            addDishModuleAssembly: addDishModuleAssembly,
            categoryModuleAssembly: categoryModuleAssembly
        )
        let categoryViewController = categoryModuleAssembly.createModule(router: categoryRouter)
        categoryNavigationController.viewControllers = [categoryViewController]
        categoryNavigationController.tabBarItem = UITabBarItem(
            title: Constants.main,
            image: UIImage(named: Constants.home),
            tag: 0
        )
        
        // Поиск
        let searchViewController = SearchViewController()
        let searchNavigationController = UINavigationController(rootViewController: searchViewController)
        searchNavigationController.tabBarItem = UITabBarItem(
            title: Constants.search,
            image: UIImage(systemName: Constants.searchImage),
            tag: 1
        )
        
        // Корзина
        let cartViewController = CartViewController()
        let cartNavigationController = UINavigationController(rootViewController: cartViewController)
        cartNavigationController.tabBarItem = UITabBarItem(
            title: Constants.cart,
            image: UIImage(systemName: Constants.cartImage),
            tag: 2
        )
        
        // Профиль пользователя
        let userViewController = UserViewController()
        let userNavigationController = UINavigationController(rootViewController: userViewController)
        userNavigationController.tabBarItem = UITabBarItem(
            title: Constants.account,
            image: UIImage(systemName: Constants.userIconImage),
            tag: 3
        )
        
        // Настройка viewControllers для TabBarController
        self.viewControllers = [
            categoryNavigationController,
            searchNavigationController,
            cartNavigationController,
            userNavigationController
        ]
    }
}
