//
//  AddDishCoordinator.swift
//  DeliveryApp
//

import UIKit

final class AddDishCoordinator: BaseCoordinator {
    // MARK: - Public properties
    var onFinish: (() -> Void)?
    
    // MARK: - Private properties
    private var assembly: AddDishModuleAssembly
    private var dish: Dish?
    
    // MARK: - init
    init(navigationController: UINavigationController, assembly: AddDishModuleAssembly, dish: Dish) {
        self.assembly = assembly
        self.dish = dish
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Override Methods
    override func start() {
        guard let dish = dish else { return }
        showAddDishScreen(dish: dish)
    }
    
    // MARK: - Public Methods
    func showAddDishScreen(dish: Dish) {
        guard let addDishViewController = assembly.createModule(dish: dish, coordinator: self) as? AddDishViewController else { return }
        
        addDishViewController.modalPresentationStyle = .overFullScreen
        addDishViewController.onCloseTapped = { [weak self] in
            self?.closeAddDishScreen()
        }
        navigationController.present(addDishViewController, animated: true)
    }
    
    func closeAddDishScreen() {
        navigationController.dismiss(animated: true) {
            self.onFinish?()
        }
    }
}
