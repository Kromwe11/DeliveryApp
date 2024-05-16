//
//  DishModuleAssembly.swift
//  DeliveryApp 
//

import UIKit

/// `DishModuleAssemblyProtocol` определяет интерфейс для сборочного модуля,
/// который создаёт экземпляры `UIViewController`, предназначенные для отображения
/// информации о блюдах в указанной категории.
protocol DishModuleAssemblyProtocol {
    /// Создаёт `UIViewController`, который используется для управления представлением блюд в категории.
    /// - Parameters:
    ///   - category: Категория блюд, для которой необходимо создать модуль.
    ///   - coordinator: Координатор, управляющий жизненным циклом создаваемого модуля.
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
        let networkMonitorService = NetworkMonitorService()
        viewModel.configure(
            networkManager: networkManager,
            realmStorageManager: realmStorageManager,
            category: category,
            coordinator: coordinator,
            networkMonitorService: networkMonitorService
        )
        let view = DishViewController()
        view.configure(viewModel: viewModel, imageService: imageService, coordinator: coordinator)
        view.title = category.name 
        return view
    }
}
