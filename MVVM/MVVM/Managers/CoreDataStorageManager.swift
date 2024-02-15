//
//  CoreDataStorageManager.swift
//  TestMVP
//
//  Created by Висент Щепетков on 30.01.2024.
//

import CoreData
import UIKit

/// `CoreDataManaging` определяет интерфейс для управления сохранением и извлечением данных моделей `Dish` и `Сategory` через Core Data.
protocol CoreDataManaging {
    /// Сохраняет объект `Dish` в постоянное хранилище.
    /// - Parameter dish: Объект `Dish`, который необходимо сохранить.
    func saveDish(_ dish: Dish)
    
    /// Извлекает все объекты `Dish` из постоянного хранилища.
    /// - Returns: Массив объектов `Dish`, извлечённых из хранилища.
    func fetchDishes() -> [Dish]
    
    /// Сохраняет объект `Сategory` в постоянное хранилище.
    /// - Parameter category: Объект `Сategory`, который необходимо сохранить.
    func saveCategory(_ category: CategoryDish)
    
    /// Извлекает все объекты `Сategory` из постоянного хранилища.
    /// - Returns: Массив объектов `Сategory`, извлечённых из хранилища.
    func fetchCategories() -> [CategoryDish]
    
    /// Проверяет, существует ли объект `Dish` с заданным ID в постоянном хранилище.
    /// - Parameter id: Идентификатор объекта `Dish`.
    /// - Returns: `true`, если объект существует, и `false` в противном случае.
    func dishExists(withID id: Int) -> Bool
    
    /// Проверяет, существует ли объект `Сategory` с заданным ID в постоянном хранилище.
    /// - Parameter id: Идентификатор объекта `Сategory`.
    /// - Returns: `true`, если объект существует, и `false` в противном случае.
    func categoryExists(withID id: Int) -> Bool
}

final class CoreDataStorageManager: CoreDataManaging {
    
    // MARK: - Private properties
    private let persistentContainer: NSPersistentContainer
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - init
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }
    
    // MARK: - Public Methods
    func saveDish(_ dish: Dish) {
        let dishEntity = DishEntity(context: viewContext)
        dishEntity.id = Int32(dish.id)
        dishEntity.name = dish.name
        dishEntity.price = Int32(dish.price)
        dishEntity.weight = Int32(dish.weight)
        dishEntity.dishDescription = dish.dishDescription
        dishEntity.imageURL = dish.imageURL
        
        if let tegsData = try? JSONEncoder().encode(dish.tegs.map { $0.rawValue }) {
            dishEntity.tegs = tegsData
        }
        
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
        }
    }
    
    func fetchDishes() -> [Dish] {
        let fetchRequest: NSFetchRequest<DishEntity> = DishEntity.fetchRequest()
        
        do {
            let dishEntities = try viewContext.fetch(fetchRequest)
            return dishEntities.compactMap { entity in
                guard let name = entity.name,
                      let dishDescription = entity.dishDescription,
                      let imageURL = entity.imageURL,
                      let tegsData = entity.tegs else { return nil }
                
                let tegsStrings = (try? JSONDecoder().decode([String].self, from: tegsData)) ?? []
                let tegs = tegsStrings.compactMap { Dish.Teg(rawValue: $0) }
                
                return Dish(
                    id: Int(entity.id),
                    name: name,
                    price: Int(entity.price),
                    weight: Int(entity.weight),
                    dishDescription: dishDescription,
                    imageURL: imageURL,
                    tegs: tegs)
            }
        } catch {
            return []
        }
    }
    
    func dishExists(withID id: Int) -> Bool {
        let fetchRequest: NSFetchRequest<DishEntity> = DishEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result.count > 0
        } catch {
            return false
        }
    }
    
    func categoryExists(withID id: Int) -> Bool {
        let fetchRequest: NSFetchRequest<CategoriesEntity> = CategoriesEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result.count > 0
        } catch {
            return false
        }
    }
    
    func saveCategory(_ category: CategoryDish) {
        guard !categoryExists(withID: category.id) else { return }
        let categoryEntity = CategoriesEntity(context: viewContext)
        categoryEntity.id = Int64(category.id)
        categoryEntity.name = category.name
        categoryEntity.imageURL = category.imageURL
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
        }
    }
    
    func fetchCategories() -> [CategoryDish] {
        let fetchRequest: NSFetchRequest<CategoriesEntity> = CategoriesEntity.fetchRequest()
        
        do {
            let categoryEntities = try viewContext.fetch(fetchRequest)
            return categoryEntities.compactMap { entity in
                guard let name = entity.name, let imageURL = entity.imageURL else { return nil }
                return CategoryDish(id: Int(entity.id), name: name, imageURL: imageURL) 
            }
        } catch {
            return []
        }
    }
}
