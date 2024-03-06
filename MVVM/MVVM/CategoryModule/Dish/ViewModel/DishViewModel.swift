//
//  DishViewModel.swift
//  MVVM
//
//  Created by Висент Щепетков on 29.02.2024.
//

import Foundation

protocol DishViewModelProtocol: AnyObject {
    var updateData: (() -> Void)? { get set }
    var presentError: ((String) -> Void)? { get set }
    var dishes: [Dish] { get set }
    var categoryName: String { get set }
    var onRequestShowAddDish: ((Dish) -> Void)? { get set }
    
    func configure(networkManager: NetworkManagerProtocol, realmStorageManager: RealmManaging, category: CategoryDish, coordinator: DishCoordinator)
    func fetchDishes()
    func filterDishes(by tag: String)
    func showAddDishScreen(dish: Dish)
}

final class DishViewModel: DishViewModelProtocol {
    var updateData: (() -> Void)?
    var presentError: ((String) -> Void)?
    var dishes: [Dish] = []
    var categoryName: String = ""
    var onRequestShowAddDish: ((Dish) -> Void)?
    
    private var networkManager: NetworkManagerProtocol?
    private var realmStorageManager: RealmManaging?
    private var category: CategoryDish?
    private var coordinator: DishCoordinator?
    
    func configure(networkManager: NetworkManagerProtocol, realmStorageManager: RealmManaging, category: CategoryDish, coordinator: DishCoordinator) {
        self.networkManager = networkManager
        self.realmStorageManager = realmStorageManager
        self.category = category
        self.coordinator = coordinator
        self.categoryName = category.name
        fetchDishes()
    }
    
    func fetchDishes() {
        guard let categoryID = category?.id else { return }
        
        networkManager?.fetchDishes(forCategoryId: categoryID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let dishResponses):
                    self?.dishes = dishResponses.compactMap { response in
                        let dish = Dish()
                        dish.id = response.id
                        dish.name = response.name
                        dish.price = response.price
                        dish.weight = response.weight
                        dish.dishDescription = response.description
                        dish.imageURL = response.imageURL
                        dish.tegs.append(objectsIn: response.tegs)
                        return dish
                    }
                    self?.dishes.forEach { self?.realmStorageManager?.saveDish($0, completion: { _ in }) }
                    self?.updateData?()
                case .failure(let error):
                    self?.presentError?(error.localizedDescription)
                }
            }
        }
    }
    
    func filterDishes(by tag: String) {
        if tag == Dish.Teg.allMenu.rawValue {
            dishes = realmStorageManager?.fetchDishes() ?? []
        } else {
            dishes = realmStorageManager?.fetchDishes().filter { $0.tegs.contains(tag) } ?? []
        }
        updateData?()
    }
    
    func showAddDishScreen(dish: Dish) {
        onRequestShowAddDish?(dish)
    }
}
