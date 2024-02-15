//
//  CategoryModuleAssembly.swift
//  TestMVP
//
//  Created by Висент Щепетков on 14.02.2024.
//

import UIKit

/// Протокол, определяющий интерфейс сборщика модуля списка категорий.
protocol CategoryModuleAssemblyProtocol {
    /// Создает экземпляр модуля для отображения списка категорий.
    /// - Parameter router: Роутер для навигации между экранами.
    /// - Returns: Контроллер представления, сконфигурированный для отображения списка категорий.
    func createModule(router: RouterProtocol) -> UIViewController
}

final class CategoryModuleAssembly: CategoryModuleAssemblyProtocol {
    // MARK: - Private properties
    private let imageService: ImageServiceProtocol
    private let coreDataStorageManager: CoreDataManaging
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Init
    init(
        imageService: ImageServiceProtocol,
        coreDataStorageManager: CoreDataManaging,
        networkManager: NetworkManagerProtocol
    ) {
        self.imageService = imageService
        self.coreDataStorageManager = coreDataStorageManager
        self.networkManager = networkManager
    }
    
    // MARK: - Public Methods
    func createModule(router: RouterProtocol) -> UIViewController {
        let view = CategoryViewController()
        let locationService = LocationService()
        let presenter = CategoryPresenter()
        
        presenter.setup(
            view: view,
            networkManager: networkManager,
            router: router,
            coreDataStorageManager: coreDataStorageManager,
            locationService: locationService)
        
        view.presenter = presenter
        view.imageService = imageService
        
        return view
    }
}
