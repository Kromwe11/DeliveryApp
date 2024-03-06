//
//  CategoryModuleAssembly.swift
//  TestMVP
//
//  Created by Висент Щепетков on 14.02.2024.
//

import UIKit

protocol CategoryModuleAssemblyProtocol {
    func createModule(coordinator: CategoryCoordinator) -> UIViewController
}

final class CategoryModuleAssembly: CategoryModuleAssemblyProtocol {
    
    // MARK: - Private properties
    private let imageService: ImageServiceProtocol
    private let realmStorageManager: RealmManaging
    private let networkManager: NetworkManagerProtocol
    
    // MARK: init
    init(
        imageService: ImageServiceProtocol,
        realmStorageManager: RealmManaging,
        networkManager: NetworkManagerProtocol
    ) {
        self.imageService = imageService
        self.realmStorageManager = realmStorageManager
        self.networkManager = networkManager
    }
    
    // MARK: Public Methods
    func createModule(coordinator: CategoryCoordinator) -> UIViewController {
        let viewModel = CategoryViewModel()
        viewModel.configure(
            networkManager: networkManager,
            realmStorageManager: realmStorageManager,
            locationService: LocationService(),
            coordinator: coordinator
        )
        let viewController = CategoryViewController()
        viewController.configure(viewModel: viewModel, imageService: imageService)
        return viewController
    }
}
