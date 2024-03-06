//
//  AddDishCoordinator.swift
//  MVVM
//
//  Created by Висент Щепетков on 04.03.2024.
//

import UIKit

final class AddDishCoordinator: BaseCoordinator {
    // MARK: - Private properties
    private var assembly: AddDishModuleAssembly
    
    // MARK: - init
    init(navigationController: UINavigationController, assembly: AddDishModuleAssembly) {
        self.assembly = assembly
        super.init(navigationController: navigationController)
    }
    
    // MARK: Public Methods
    func showAddDishScreen(dish: Dish) {
        let addDishViewController = assembly.createModule(dish: dish, coordinator: self)
        addDishViewController.modalPresentationStyle = .overFullScreen
        navigationController.present(addDishViewController, animated: true)
    }
}
