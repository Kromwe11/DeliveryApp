//
//  AddDishModuleAssembly.swift
//  TestMVP
//
//  Created by Висент Щепетков on 14.02.2024.
//

import UIKit

protocol AddDishModuleAssemblyProtocol {
    func createModule(dish: Dish, coordinator: AddDishCoordinator) -> UIViewController
}

final class AddDishModuleAssembly: AddDishModuleAssemblyProtocol {
    // MARK: - Private properties
    private let imageService: ImageServiceProtocol
    
    // MARK: - init
    init(imageService: ImageServiceProtocol) {
        self.imageService = imageService
    }
    
    // MARK: - Public Methods
    func createModule(dish: Dish, coordinator: AddDishCoordinator) -> UIViewController {
        let viewModel = AddDishViewModel()
        viewModel.configure(dish: dish, imageService: imageService)

        let view = AddDishViewController()
        view.configure(viewModel: viewModel)

        return view
    }
}
