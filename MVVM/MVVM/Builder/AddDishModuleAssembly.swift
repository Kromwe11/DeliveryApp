//
//  AddDishModuleAssembly.swift
//  TestMVP
//
//  Created by Висент Щепетков on 14.02.2024.
//

import UIKit

/// Протокол, определяющий интерфейс сборщика модуля добавления блюда.
protocol AddDishModuleAssemblyProtocol {
    /// Создает экземпляр модуля для добавления блюда.
    /// - Parameters:
    ///   - dish: Объект блюда, который будет добавлен или редактирован.
    ///   - router: Роутер для навигации между экранами.
    /// - Returns: Контроллер представления, сконфигурированный для добавления блюда.
    func createModule(dish: Dish, router: RouterProtocol) -> UIViewController
}

final class AddDishModuleAssembly: AddDishModuleAssemblyProtocol {
    
    // MARK: - Private properties
    private let imageService: ImageServiceProtocol
    private let coreDataStorageManager: CoreDataManaging
    
    // MARK: - Init
    init(imageService: ImageServiceProtocol, coreDataStorageManager: CoreDataManaging) {
        self.imageService = imageService
        self.coreDataStorageManager = coreDataStorageManager
    }
    
    // MARK: - Public Methods
    func createModule(dish: Dish, router: RouterProtocol) -> UIViewController {
        let view = AddDishViewController()
        let presenter = AddDishPresenter()
        
        presenter.setup(view: view, dish: dish, router: router, coreDataStorageManager: coreDataStorageManager)
        
        view.presenter = presenter
        view.imageService = imageService
        
        return view
    }
}
