//
//  DishModuleAssembly.swift
//  TestMVP
//
//  Created by Висент Щепетков on 14.02.2024.
//

import UIKit

/// Протокол, определяющий интерфейс сборщика модуля списка блюд категории.
protocol DishModuleAssemblyProtocol {
    /// Создает экземпляр модуля для отображения блюд определенной категории.
    /// - Parameters:
    ///   - router: Роутер для навигации между экранами.
    ///   - category: Категория, блюда которой будут отображаться.
    /// - Returns: Контроллер представления, сконфигурированный для отображения блюд категории.
    func createModule(router: RouterProtocol, category: CategoryDish) -> UIViewController
}

final class DishModuleAssembly: DishModuleAssemblyProtocol {
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
    func createModule(router: RouterProtocol, category: CategoryDish) -> UIViewController {
        let view = DishViewController()
        let presenter = DishPresenter()
        
        presenter.setup(
            view: view,
            networkManager: networkManager,
            router: router, 
            category: category,
            coreDataStorageManager: coreDataStorageManager)
        
        view.presenter = presenter
        view.imageService = imageService
        
        return view
    }
}
