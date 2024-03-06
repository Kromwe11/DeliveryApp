//
//  NetworkManager.swift
//  TestMVP
//
//  Created by Висент Щепетков on 25.01.2024.
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
    func fetchCategories(completion: @escaping (Result<[CategoryResponse], Error>) -> Void) {
        guard let url = URL(string: "https://run.mocky.io/v3/ac1e983b-0ad7-4d68-8a26-8b845e0b7609") else {
            completion(.failure(NetworkError.otherError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.requestFailed))
                return
            }
            
            print(data)
            
            do {
                let decodedData = try JSONDecoder().decode(CategoriesResponse.self, from: data)
                completion(.success(decodedData.categories))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchDishes(forCategoryId categoryId: Int, completion: @escaping (Result<[DishResponse], Error>) -> Void) {
        guard let url = URL(string: "https://run.mocky.io/v3/a013eb83-8059-44d6-a880-893baaa18ad6") else {
            completion(.failure(NetworkError.otherError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.requestFailed))
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
