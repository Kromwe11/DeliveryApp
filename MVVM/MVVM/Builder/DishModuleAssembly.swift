//
//  DishModuleAssembly.swift
//  TestMVP
//
//  Created by Висент Щепетков on 14.02.2024.
//

import UIKit

protocol DishModuleAssemblyProtocol {
    func createModule(category: CategoryDish, coordinator: DishCoordinator) -> UIViewController
}

final class DishModuleAssembly: DishModuleAssemblyProtocol {
    // MARK: - Private properties
    private let imageService: ImageServiceProtocol
    private let realmStorageManager: RealmManaging
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - init
    init(
        imageService: ImageServiceProtocol,
        realmStorageManager: RealmManaging,
        networkManager: NetworkManagerProtocol
    ) {
        self.imageService = imageService
        self.realmStorageManager = realmStorageManager
        self.networkManager = networkManager
    }
    
    // MARK: - Public Methods
    func createModule(category: CategoryDish, coordinator: DishCoordinator) -> UIViewController {
        let viewModel = DishViewModel()
        viewModel.configure(
            networkManager: networkManager,
            realmStorageManager: realmStorageManager,
            category: category,
            coordinator: coordinator
        )
        let view = DishViewController()
        view.configure(viewModel: viewModel, imageService: imageService, coordinator: coordinator)
        
        return view
    }
}
