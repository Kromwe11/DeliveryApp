//
//  DishCoordinator.swift
//  MVVM
//
//  Created by Висент Щепетков on 04.03.2024.
//

import UIKit

final class DishCoordinator: BaseCoordinator {
    // MARK: - Private properties
    private var category: CategoryDish
    private var assembly: DishModuleAssembly
    private var addDishAssembly: AddDishModuleAssembly
    
    // MARK: - init
    init(
        navigationController: UINavigationController,
        category: CategoryDish,
        assembly: DishModuleAssembly,
        addDishAssembly: AddDishModuleAssembly
    ) {
        self.category = category
        self.assembly = assembly
        self.addDishAssembly = addDishAssembly
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Override Methods
    override func start() {
        let dishViewController = assembly.createModule(category: category, coordinator: self)
        navigationController.pushViewController(dishViewController, animated: true)
    }
    
    // MARK: Public Methods
    func showAddDishScreen(dish: Dish) {
        let dishToEdit = dish
        let addDishCoordinator = AddDishCoordinator(
            navigationController: navigationController,
            assembly: addDishAssembly
        )
        addDishCoordinator.showAddDishScreen(dish: dishToEdit)
    }
}
