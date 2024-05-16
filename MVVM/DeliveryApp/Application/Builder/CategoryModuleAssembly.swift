//
//  CategoryModuleAssembly.swift
//  DeliveryApp 
//

import UIKit

/// `CategoryModuleAssemblyProtocol` определяет интерфейс для сборочного модуля,
/// который создает экземпляры `UIViewController` для управления и отображения категорий блюд.
protocol CategoryModuleAssemblyProtocol {
    /// Создает `UIViewController`, который используется для управления представлением категорий блюд.
    /// Этот метод отвечает за создание и конфигурацию `UIViewController`, который интегрируется
    /// - Parameters:
    ///   - coordinator: Координатор, который управляет процессом отображения и навигации по категориям блюд.
    /// - Returns: Возвращает экземпляр `UIViewController`, настроенный для управления категориями блюд.
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
        let locationService = LocationService()
        let networkMonitorService = NetworkMonitorService()
        
        let viewModel = CategoryViewModel()
        viewModel.configure(
            networkManager: networkManager,
            realmStorageManager: realmStorageManager,
            locationService: locationService,
            networkMonitorService: networkMonitorService,
            coordinator: coordinator
        )
        
        let viewController = CategoryViewController()
        viewController.configure(viewModel: viewModel, imageService: imageService)
        
        return viewController
    }
}
