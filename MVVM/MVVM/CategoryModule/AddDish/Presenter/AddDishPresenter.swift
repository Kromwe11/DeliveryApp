//
//  AddDishPresenter.swift
//  TestMVP
//
//  Created by Висент Щепетков on 26.01.2024.
//

import Foundation

/// Протокол представления для экрана добавления блюда.
protocol AddDishViewProtocol: AnyObject {
    /// Отображает детали блюда.
    /// - Parameter dish: Объект блюда, детали которого нужно отобразить.
    func displayDishDetails(_ dish: Dish)
}

/// Протокол представителя для управления логикой на экране добавления блюда.
protocol AddDishPresenterProtocol: AnyObject {
    /// Настраивает представитель и связанные с ним компоненты.
    /// - Parameters:
    ///   - view: Вью, которое представитель будет обновлять.
    ///   - dish: Блюдо для отображения или редактирования.
    ///   - router: Роутер для навигации между экранами.
    ///   - coreDataStorageManager: Менеджер для работы с локальным хранилищем данных.
    func setup(
        view: AddDishViewProtocol,
        dish: Dish,
        router: RouterProtocol,
        coreDataStorageManager: CoreDataManaging)

    /// Запрашивает и отображает детали блюда.
    func getDishDetails()
}

final class AddDishPresenter: AddDishPresenterProtocol {
    
    // MARK: - Private Properties
    private var dish: Dish!
    weak private var view: AddDishViewProtocol?
    private var router: RouterProtocol?
    private var coreDataStorageManager: CoreDataManaging?
    
    // MARK: - Public Methods
    func setup(
        view: AddDishViewProtocol,
        dish: Dish,
        router: RouterProtocol,
        coreDataStorageManager: CoreDataManaging
    ) {
        self.view = view
        self.dish = dish
        self.router = router
        self.coreDataStorageManager = coreDataStorageManager
        getDishDetails()
    }
    
    func getDishDetails() {
        view?.displayDishDetails(dish)
    }
}
