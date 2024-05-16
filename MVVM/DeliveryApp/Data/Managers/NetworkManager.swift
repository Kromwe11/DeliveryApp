//
//  NetworkManager.swift
//  DeliveryApp
//

import Foundation

/// Протокол `NetworkManagerProtocol` определяет интерфейс для сетевых запросов, связанных с извлечением данных
protocol NetworkManagerProtocol {
    /// Выполняет запрос на извлечение списка категорий.
    /// - Parameter completion: Блок завершения, который вызывается при получении ответа.
    ///   В случае успеха возвращает массив объектов `Сategory`, в случае неудачи - ошибку.
    func fetchCategories(completion: @escaping (Result<[CategoryResponse], Error>) -> Void)
    
    /// Выполняет запрос на извлечение списка блюд для определённой категории.
    /// - Parameters:
    ///   - categoryId: Идентификатор категории, для которой необходимо извлечь список блюд.
    ///   - completion: Блок завершения, который вызывается при получении ответа.
    ///     В случае успеха возвращает массив объектов `Dish`, в случае неудачи - ошибку.
    func fetchDishes(forCategoryId categoryId: Int, completion: @escaping (Result<[DishResponse], Error>) -> Void)
}

final class NetworkManager: NetworkManagerProtocol {
        
    // MARK: - Public Methods
    func fetchCategories(completion: @escaping (Result<[CategoryResponse], Error>) -> Void) {
        guard let url = URL(string: "https://run.mocky.io/v3/3061b929-6358-4ffc-868a-4ab90846d7a5") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.serverError))
                return
            }
                        
            do {
                let decodedData = try JSONDecoder().decode(CategoriesResponse.self, from: data)
                completion(.success(decodedData.сategories))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchDishes(forCategoryId categoryId: Int, completion: @escaping (Result<[DishResponse], Error>) -> Void) {
        guard let url = URL(string: "https://run.mocky.io/v3/1db5af8a-1ebe-448c-b8ae-9c6aea465424") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.serverError))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(DishesResponse.self, from: data)
                completion(.success(decodedData.dishes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
