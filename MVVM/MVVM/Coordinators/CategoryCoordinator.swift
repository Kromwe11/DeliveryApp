//
//  CategoryCoordinator.swift
//  MVVM
//
//  Created by Висент Щепетков on 04.03.2024.
//

import UIKit

final class CategoryCoordinator: BaseCoordinator {
    
    // MARK: - Private properties
    private var assembly: CategoryModuleAssembly
    private let dishAssembly: DishModuleAssemblyProtocol
    private var addDishAssembly: AddDishModuleAssembly
    
    // MARK: - init
    init(
        navigationController: UINavigationController, 
        assembly: CategoryModuleAssembly,
        dishAssembly: DishModuleAssemblyProtocol,
        addDishAssembly: AddDishModuleAssembly
    ) {
        self.assembly = assembly
        self.dishAssembly = dishAssembly
        self.addDishAssembly = addDishAssembly
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Override Methods
    override func start() {
        let viewController = assembly.createModule(coordinator: self)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: Public Methods
    func showDishList(for category: CategoryDish) {
        let dishCoordinator = DishCoordinator(
            navigationController: navigationController,
            category: category,
            assembly: dishAssembly as! DishModuleAssembly,
            addDishAssembly: addDishAssembly
        )
        dishCoordinator.start()
    }
}
