//
//  NetworkManager.swift
//  TestMVP
//
//  Created by Висент Щепетков on 25.01.2024.
//

import Alamofire
import Foundation

/// Протокол `NetworkManagerProtocol` определяет интерфейс для сетевых запросов, связанных с извлечением данных
protocol NetworkManagerProtocol {
    /// Выполняет запрос на извлечение списка категорий.
    /// - Parameter completion: Блок завершения, который вызывается при получении ответа.
    ///   В случае успеха возвращает массив объектов `Сategory`, в случае неудачи - ошибку.
    func fetchCategories(completion: @escaping (Result<[CategoryDish], Error>) -> Void)
    
    /// Выполняет запрос на извлечение списка блюд для определённой категории.
    /// - Parameters:
    ///   - categoryId: Идентификатор категории, для которой необходимо извлечь список блюд.
    ///   - completion: Блок завершения, который вызывается при получении ответа.
    ///     В случае успеха возвращает массив объектов `Dish`, в случае неудачи - ошибку.
    func fetchDishes(forCategoryId categoryId: Int, completion: @escaping (Result<[Dish], Error>) -> Void)
}

final class NetworkManager: NetworkManagerProtocol {
    
    // MARK: - Public Methods
    func fetchCategories(completion: @escaping (Result<[CategoryDish], Error>) -> Void) {
        AF.request("https://run.mocky.io/v3/ac1e983b-0ad7-4d68-8a26-8b845e0b7609").responseDecodable(of: Сategories.self) { response in
            switch response.result {
            case .success(let categoriesData):
                completion(.success(categoriesData.сategories))
            case .failure(let error):
                if let afError = error.asAFError, afError.isSessionTaskError {
                    completion(.failure(NetworkError.connectionError))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchDishes(forCategoryId categoryId: Int, completion: @escaping (Result<[Dish], Error>) -> Void) {
        let url = "https://run.mocky.io/v3/a013eb83-8059-44d6-a880-893baaa18ad6"
        AF.request(url).responseDecodable(of: Dishes.self) { response in
            switch response.result {
            case .success(let dishesData):
                completion(.success(dishesData.dishes))
            case .failure(let error):
                if let afError = error.asAFError, afError.isSessionTaskError {
                    completion(.failure(NetworkError.connectionError))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}
