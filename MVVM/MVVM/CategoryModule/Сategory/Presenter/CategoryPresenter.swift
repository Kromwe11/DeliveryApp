//
//  CategoryPresenter.swift
//  TestMVP
//
//  Created by Висент Щепетков on 25.01.2024.
//

import CoreLocation
import Foundation

/// Протокол представления для отображения категорий.
protocol CategoryViewProtocol: AnyObject {
    /// Отображает категории в представлении.
    /// - Parameter categories: Список категорий для отображения.
    func displayCategories(_ categories: [CategoryDish])
    
    /// Отображает ошибку, если категории не могут быть загружены.
    /// - Parameter error: Ошибка, возникшая при попытке загрузки категорий.
    func displayError(_ error: Error)
    
    /// Обновляет название города в представлении.
    /// - Parameter cityName: Название города для отображения.
    func updateCityName(_ cityName: String)
}

/// Протокол презентера для взаимодействия с представлением категорий.
protocol CategoryViewPresenterProtocol: AnyObject {
    /// Настраивает презентер.
    /// - Parameters:
    ///   - view: Представление, которое презентер будет обновлять.
    ///   - networkManager: Сервис для выполнения сетевых запросов.
    ///   - router: Роутер для навигации между экранами.
    ///   - coreDataStorageManager: Менеджер для работы с coreData.
    ///   - locationService: Сервис для работы с геолокацией.
    func setup(
        view: CategoryViewProtocol,
        networkManager: NetworkManagerProtocol,
        router: RouterProtocol,
        coreDataStorageManager: CoreDataManaging,
        locationService: LocationServiceProtocol)
    
    /// Загружает и отображает категории.
    func getCategories()
    
    /// Обрабатывает выбор категории пользователем.
    /// - Parameter category: Выбранная категория.
    func didSelectCategory(category: CategoryDish?)
    
    /// Возвращает количество доступных категорий.
    func getCategoriesCount() -> Int
    
    /// Возвращает категорию по заданному индексу.
    /// - Parameter index
    func getCategory(at index: Int) -> CategoryDish?
}

final class CategoryPresenter: CategoryViewPresenterProtocol, LocationServiceDelegate {
    
    // MARK: - Private properties
    weak private var view: CategoryViewProtocol?
    private var router: RouterProtocol?
    private var networkManager: NetworkManagerProtocol?
    private var coreDataStorageManager: CoreDataManaging?
    private var locationService: LocationServiceProtocol?
    private var categories: [CategoryDish] = []
    private enum Constants {
        static let placeholder = "placeholder"
    }
    
    // MARK: - Public Methods
    func setup(
        view: CategoryViewProtocol,
        networkManager: NetworkManagerProtocol,
        router: RouterProtocol,
        coreDataStorageManager: CoreDataManaging,
        locationService: LocationServiceProtocol) {
        self.view = view
        self.networkManager = networkManager
        self.router = router
        self.coreDataStorageManager = coreDataStorageManager
        self.locationService = locationService
        
        self.locationService?.delegate = self
        self.locationService?.startUpdatingLocation()
        getCategories()
    }
    
    func getCategories() {
        networkManager?.fetchCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = categories
                    for category in categories where !(self?.coreDataStorageManager?.categoryExists(withID: category.id) ?? true) {
                        self?.coreDataStorageManager?.saveCategory(category)
                    }
                    self?.view?.displayCategories(categories)
                case .failure(let error):
                    let cachedCategories = self?.coreDataStorageManager?.fetchCategories() ?? []
                    if !cachedCategories.isEmpty {
                        self?.categories = cachedCategories
                        self?.view?.displayCategories(cachedCategories)
                    } else {
                        self?.view?.displayError(error)
                    }
                }
            }
        }
    }
    
    func didSelectCategory(category: CategoryDish?) {
        guard let category = category else { return }
        router?.showDishScreen(category: category)
    }
    
    func getCategoriesCount() -> Int {
        return categories.count
    }
    
    func getCategory(at index: Int) -> CategoryDish? {
        guard index >= 0 && index < categories.count else { return nil }
        return categories[index]
    }
    
    func didUpdateLocations(_ locations: [CLLocation]) {
        guard let location = locations.first else { return }
        lookUpCurrentLocation(location: location)
    }
    
    func didFailWithError(_ error: Error) {
        view?.updateCityName("\(error.localizedDescription)")
    }
    
    // MARK: - Private Methods
    private func lookUpCurrentLocation(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if error == nil, let city = placemarks?.first?.locality {
                self?.view?.updateCityName(city)
            } else {
                self?.view?.updateCityName("Unknown location")
            }
        }
    }
}
