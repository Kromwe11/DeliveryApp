//
//  DishViewModel.swift
//  DeliveryApp
//

import Foundation

/// `DishViewModelProtocol` определяет интерфейс для ViewModel, который управляет отображением и взаимодействием
/// с данными блюд в приложении. Этот протокол обеспечивает функции для загрузки, фильтрации блюд,
/// управления навигацией для добавления блюд, а также обработки уведомлений об ошибках и обновлений данных.
protocol DishViewModelProtocol: AnyObject {
    /// Коллбэк для обновления данных на пользовательском интерфейсе.
    var updateData: (() -> Void)? { get set }
    
    /// Коллбэк для отображения сообщений об ошибках пользователю.
    var presentAlert: ((String) -> Void)? { get set }
    
    /// Коллбэк для запроса отображения экрана добавления блюда.
    var onRequestShowAddDish: ((Dish) -> Void)? { get set }
    
    /// Инициирует процесс загрузки списка блюд, используя доступные сетевые и кэшированные данные.
    func fetchDishes()
    
    /// Фильтрует список блюд по заданному тегу.
    /// - Parameter tag: Тег, по которому производится фильтрация блюд.
    func filterDishes(by tag: String)
    
    /// Запрашивает показ экрана для добавления нового блюда.
    /// - Parameter dish: Объект `Dish`, который должен быть добавлен.
    func showAddDishScreen(dish: Dish)
    
    /// Возвращает текущий список блюд.
    /// - Returns: Массив объектов `Dish`, представляющих текущие блюда.
    func getDishes() -> [Dish]
}

final class DishViewModel: DishViewModelProtocol {
    
    // MARK: - Public properties
    var updateData: (() -> Void)?
    var presentAlert: ((String) -> Void)?
    var onRequestShowAddDish: ((Dish) -> Void)?
    
    // MARK: - Private properties
    private var networkManager: NetworkManagerProtocol?
    private var realmStorageManager: RealmManaging?
    private var category: CategoryDish?
    private var coordinator: DishCoordinator?
    private var networkMonitorService: NetworkMonitorServiceProtocol?
    private var dishes: [Dish] = []
    
    // MARK: Public Methods
    func configure(
        networkManager: NetworkManagerProtocol,
        realmStorageManager: RealmManaging,
        category: CategoryDish,
        coordinator: DishCoordinator,
        networkMonitorService: NetworkMonitorServiceProtocol
    ) {
        self.networkManager = networkManager
        self.realmStorageManager = realmStorageManager
        self.category = category
        self.coordinator = coordinator
        self.networkMonitorService = networkMonitorService
        fetchDishes()
    }
    
    func fetchDishes() {
        guard let networkMonitorService = networkMonitorService else { return }
        networkMonitorService.checkNetworkAvailability { [weak self] isAvailable in
            if isAvailable {
                self?.fetchDishesFromNetwork()
            } else {
                self?.fetchDishesFromCache()
            }
        }
    }
    
    func filterDishes(by tag: String) {
        let allDishes: [Dish] = realmStorageManager?.fetchObjects(Dish.self) ?? []
        dishes = tag == Dish.Tag.allMenu.localized ? allDishes : allDishes.filter { $0.tegs.contains(tag) }
        updateData?()
    }
    
    func showAddDishScreen(dish: Dish) {
        onRequestShowAddDish?(dish)
    }
    
    func getDishes() -> [Dish] {
        return dishes
    }
    
    // MARK: Private Methods
    private func fetchDishesFromNetwork() {
        guard let categoryID = category?.id else { return }
        networkManager?.fetchDishes(forCategoryId: categoryID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let dishResponses):
                    self?.dishes = dishResponses.map { Dish(from: $0) }
                    self?.realmStorageManager?.saveObjects(self?.dishes ?? [])
                    self?.updateData?()
                case .failure(let error):
                    self?.presentAlert?(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchDishesFromCache() {
        let cachedDishes: [Dish] = realmStorageManager?.fetchObjects(Dish.self) ?? []
        dishes = cachedDishes
        updateData?()
    }
}
