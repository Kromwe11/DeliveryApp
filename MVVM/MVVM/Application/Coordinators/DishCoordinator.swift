//
//  DishCoordinator.swift
//  DeliveryApp
//

import UIKit

final class DishCoordinator: BaseCoordinator {
    // MARK: - Public properties
    var onFinish: (() -> Void)?
    
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
        let addDishCoordinator = AddDishCoordinator(
            navigationController: navigationController,
            assembly: addDishAssembly, 
            dish: dish
        )
        addDependency(addDishCoordinator)
        addDishCoordinator.start()
        addDishCoordinator.onFinish = { [weak self, weak addDishCoordinator] in
            self?.removeDependency(addDishCoordinator)
        }
    }
}
