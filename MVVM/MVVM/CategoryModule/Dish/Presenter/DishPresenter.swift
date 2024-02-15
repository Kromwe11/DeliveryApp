//
//  DishPresenter.swift
//  TestMVP
//
//  Created by Висент Щепетков on 26.01.2024.
//

import Foundation

/// Протокол для взаимодействия с представлением, отображающим блюда.
protocol DishViewProtocol: AnyObject {
    /// Отображает список блюд на экране.
    /// - Parameter dishes: Массив блюд для отображения.
    func displayDishes(_ dishes: [Dish])

    /// Отображает ошибку, если произошла во время загрузки блюд.
    /// - Parameter error: Ошибка, которая должна быть отображена.
    func displayError(_ error: Error)
}

/// Протокол для управления логикой представления списка блюд.
protocol DishPresenterProtocol: AnyObject {
    /// Настраивает представление и его зависимости.
    /// - Parameters:
    ///   - view: Представление, которое будет обновляться.
    ///   - networkManager: Менеджер сети для загрузки данных о блюдах.
    ///   - router: Роутер для навигации.
    ///   - category: Категория, блюда которой должны быть отображены.
    ///   - coreDataStorageManager: Менеджер для работы с локальным хранилищем данных.
    func setup(
        view: DishViewProtocol,
        networkManager: NetworkManagerProtocol,
        router: RouterProtocol,
        category: CategoryDish,
        coreDataStorageManager: CoreDataManaging)

    /// Запрашивает блюда у сервера или из кэша и отображает их.
    func getDishes()

    /// Фильтрует список блюд по заданному тегу.
    /// - Parameter teg: Тег, по которому должна быть выполнена фильтрация.
    func filterDishes(by teg: Dish.Teg)

    /// Показывает экран добавления блюда.
    /// - Parameter dish: Блюдо, которое может быть добавлено или редактируется.
    func showAddDishScreen(dish: Dish)

    /// Возвращает текущую категорию.
    /// - Returns: Текущая категория.
    func getCategory() -> CategoryDish

    /// Возвращает все блюда без фильтрации.
    /// - Returns: Массив всех блюд.
    func getAllDishes() -> [Dish]

    /// Возвращает блюда после фильтрации.
    /// - Returns: Массив отфильтрованных блюд.
    func getFilteredDishes() -> [Dish]
}

final class DishPresenter: DishPresenterProtocol {
    
    // MARK: - Private properties
    private weak var view: DishViewProtocol?
    private var networkManager: NetworkManagerProtocol?
    private var router: RouterProtocol?
    private var category: CategoryDish?
    private var coreDataStorageManager: CoreDataManaging?
    private var allDishes: [Dish] = []
    private var filteredDishes: [Dish] = []
    
    // MARK: - Public Methods
    func setup(
        view: DishViewProtocol,
        networkManager: NetworkManagerProtocol,
        router: RouterProtocol,
        category: CategoryDish,
        coreDataStorageManager: CoreDataManaging) {
        self.view = view
        self.networkManager = networkManager
        self.router = router
        self.category = category
        self.coreDataStorageManager = coreDataStorageManager
        getDishes()
    }
    
    func getDishes() {
        guard let categoryID = category?.id else { return }
        networkManager?.fetchDishes(forCategoryId: categoryID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let dishes):
                    self?.allDishes = dishes
                    self?.filteredDishes = dishes
                    for dish in dishes where !(self?.coreDataStorageManager?.dishExists(withID: dish.id) ?? true) {
                        self?.coreDataStorageManager?.saveDish(dish)
                    }
                    self?.view?.displayDishes(dishes)
                case .failure(let error):
                    let cachedDishes = self?.coreDataStorageManager?.fetchDishes() ?? []
                    if !cachedDishes.isEmpty {
                        self?.allDishes = cachedDishes
                        self?.filteredDishes = cachedDishes
                        self?.view?.displayDishes(cachedDishes)
                    } else {
                        self?.view?.displayError(error)
                    }
                }
            }
        }
    }
    
    func filterDishes(by teg: Dish.Teg) {
        filteredDishes = teg == .allMenu ? allDishes : allDishes.filter { $0.tegs.contains(teg) }
        view?.displayDishes(filteredDishes)
    }
    
    func showAddDishScreen(dish: Dish) {
        router?.showAddDishScreen(dish: dish)
    }
    
    func getCategory() -> CategoryDish {
        return category ?? CategoryDish(id: 0, name: "", imageURL: "")
    }
    
    func getAllDishes() -> [Dish] {
        return allDishes
    }
    
    func getFilteredDishes() -> [Dish] {
        return filteredDishes
    }
}
