//
//  CategoryViewModel.swift
//  DeliveryApp
//

import CoreLocation
import Foundation

import Foundation

/// `CategoryViewModelProtocol` определяет интерфейс для ViewModel, который управляет отображением и взаимодействием
/// с данными категорий блюд. Этот протокол обеспечивает функции для конфигурации, загрузки категорий,
/// обработки выбора категории, а также уведомления о необходимости обновления данных и отображения ошибок.
protocol CategoryViewModelProtocol: AnyObject {
    /// Коллбэк для обновления данных на пользовательском интерфейсе.
    var updateData: (() -> ())? { get set }
    
    /// Коллбэк для отображения сообщений об ошибках пользователю.
    var presentAlert: ((String) -> Void)? { get set }
    
    /// Коллбэк для обновления названия города на пользовательском интерфейсе.
    var updateCityName: ((String) -> Void)? { get set }
    
    /// Настраивает ViewModel с необходимыми зависимостями для работы с данными и навигацией.
    /// - Parameters:
    ///   - networkManager: Сервис для работы с сетевыми запросами.
    ///   - realmStorageManager: Сервис для работы с локальным хранилищем данных.
    ///   - locationService: Сервис для работы с геолокацией.
    ///   - networkMonitorService: Сервис для мониторинга состояния сети.
    ///   - coordinator: Координатор для управления навигацией на уровне категорий.
    func configure(
        networkManager: NetworkManagerProtocol,
        realmStorageManager: RealmManaging,
        locationService: LocationServiceProtocol,
        networkMonitorService: NetworkMonitorServiceProtocol,
        coordinator: CategoryCoordinator
    )
    /// Запускает процесс загрузки категорий, используя доступные сетевые и кэшированные данные.
    func fetchCategories()
    
    /// Обрабатывает выбор категории пользователем.
    /// - Parameter category: Опциональный объект `CategoryDish`, выбранный пользователем.
    func didSelectCategory(category: CategoryDish?)
    
    /// Возвращает текущий список категорий.
    /// - Returns: Массив объектов `CategoryDish`, представляющих доступные категории.
    func getCategories() -> [CategoryDish]
}

final class CategoryViewModel: CategoryViewModelProtocol {
    // MARK: - Public properties
    var updateData: (() -> ())?
    var presentAlert: ((String) -> Void)?
    var updateCityName: ((String) -> Void)?
    weak var coordinator: CategoryCoordinator?
    
    // MARK: - Private properties
    private var networkManager: NetworkManagerProtocol?
    private var realmStorageManager: RealmManaging?
    private var locationService: LocationServiceProtocol?
    private var networkMonitorService: NetworkMonitorServiceProtocol?
    private var categories: [CategoryDish] = []
    
    // MARK: Public Methods
    func configure(networkManager: NetworkManagerProtocol, realmStorageManager: RealmManaging, locationService: LocationServiceProtocol, networkMonitorService: NetworkMonitorServiceProtocol, coordinator: CategoryCoordinator) {
        self.networkManager = networkManager
        self.realmStorageManager = realmStorageManager
        self.locationService = locationService
        self.networkMonitorService = networkMonitorService
        self.coordinator = coordinator
        
        self.locationService?.delegate = self
        self.networkMonitorService?.startMonitoring()
        fetchCategories()
    }
    
    func fetchCategories() {
        networkMonitorService?.checkNetworkAvailability { [weak self] isAvailable in
            if isAvailable {
                self?.fetchCategoriesFromNetwork()
            } else {
                self?.loadCategoriesFromCache()
            }
        }
    }
    
    func didSelectCategory(category: CategoryDish?) {
        guard let category = category else { return }
        coordinator?.showDishList(for: category)
    }
    
    func getCategories() -> [CategoryDish] {
        return categories
    }
    
    // MARK: Private Methods
    private func fetchCategoriesFromNetwork() {
        networkManager?.fetchCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categoryResponses):
                    let categories = categoryResponses.map { CategoryDish(value: ["id": $0.id, "name": $0.name, "imageURL": $0.imageURL]) }
                    self?.realmStorageManager?.saveObjects(categories)
                    self?.categories = categories
                    self?.updateData?()
                case .failure(let error):
                    self?.presentAlert?(error.localizedDescription)
                }
            }
        }
    }
    
    private func loadCategoriesFromCache() {
        let cachedCategories: [CategoryDish] = realmStorageManager?.fetchObjects(CategoryDish.self) ?? []
        if !cachedCategories.isEmpty {
            categories = cachedCategories
            updateCityName?(L10n.networkError)
            updateData?()
        } else {
            presentAlert?(L10n.networkError)
        }
    }
}

// MARK: - LocationServiceDelegate
extension CategoryViewModel: LocationServiceDelegate {
    
    func didUpdateLocations(_ locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            if let placemarks = placemarks, let placemark = placemarks.first, let city = placemark.locality {
                self?.updateCityName?(city)
            } else {
                self?.updateCityName?(L10n.networkError)
            }
        }
    }
    
    func didFailWithError(_ error: Error) {
        updateCityName?(error.localizedDescription)
    }
}
