//
//  Router.swift
//  TestMVP
//
//  Created by Висент Щепетков on 25.01.2024.
//

import UIKit

/// Основной протокол роутера, определяющий интерфейс для навигационного контроллера.
protocol RouterMainProtocol {
    /// Навигационный контроллер, используемый для навигации.
    var navigationController: UINavigationController? { get set }
}

/// Протокол роутера, расширяющий основной протокол навигации и добавляющий специфические методы перехода между экранами.
protocol RouterProtocol: RouterMainProtocol {
    /// Отображает экран со списком блюд определенной категории.
    /// - Parameter category: Категория, блюда которой будут отображаться.
    func showDishScreen(category: CategoryDish)
    
    /// Отображает экран добавления нового блюда.
    /// - Parameter dish: Блюдо для добавления или редактирования.
    func showAddDishScreen(dish: Dish)
}

final class Router: RouterProtocol {
    // MARK: - Public properties
    var navigationController: UINavigationController?
    
    // MARK: - Private properties
    private var dishModuleAssembly: DishModuleAssemblyProtocol
    private var addDishModuleAssembly: AddDishModuleAssemblyProtocol

    // MARK: - Init
    init(
        navigationController: UINavigationController,
        dishModuleAssembly: DishModuleAssemblyProtocol,
        addDishModuleAssembly: AddDishModuleAssemblyProtocol,
        categoryModuleAssembly: CategoryModuleAssemblyProtocol
    ) {
        self.navigationController = navigationController
        self.dishModuleAssembly = dishModuleAssembly
        self.addDishModuleAssembly = addDishModuleAssembly
    }
    
    // MARK: - Public Methods
    func showDishScreen(category: CategoryDish) {
        let viewController = dishModuleAssembly.createModule(router: self, category: category)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showAddDishScreen(dish: Dish) {
        let viewController = addDishModuleAssembly.createModule(dish: dish, router: self)
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .overFullScreen
        navigationController?.present(navController, animated: true)
    }
}
