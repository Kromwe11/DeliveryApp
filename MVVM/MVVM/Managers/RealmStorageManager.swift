//
//  RealmStorageManager.swift
//  MVVM
//
//  Created by Висент Щепетков on 05.03.2024.
//

import Foundation
import RealmSwift

protocol RealmManaging {
    func saveDish(_ dish: Dish, completion: @escaping (Error?) -> Void)
    func fetchDishes() -> [Dish]
    func saveCategory(_ category: CategoryDish, completion: @escaping (Error?) -> Void)
    func fetchCategories() -> [CategoryDish]
    func dishExists(withID id: Int) -> Bool
    func categoryExists(withID id: Int) -> Bool
}

final class RealmStorageManager: RealmManaging {
    private var realm: Realm {
        return try! Realm()
    }
    
    func saveDish(_ dish: Dish, completion: @escaping (Error?) -> Void) {
        do {
            try realm.write {
                realm.add(dish, update: .modified)
                completion(nil)
            }
        } catch {
            completion(error)
        }
    }
    
    func fetchDishes() -> [Dish] {
        return Array(realm.objects(Dish.self))
    }
    
    func saveCategory(_ category: CategoryDish, completion: @escaping (Error?) -> Void) {
        do {
            try realm.write {
                realm.add(category, update: .modified)
                completion(nil)
            }
        } catch {
            completion(error)
        }
    }
    
    func fetchCategories() -> [CategoryDish] {
        return Array(realm.objects(CategoryDish.self))
    }
    
    func dishExists(withID id: Int) -> Bool {
        return realm.object(ofType: Dish.self, forPrimaryKey: id) != nil
    }
    
    func categoryExists(withID id: Int) -> Bool {
        return realm.object(ofType: CategoryDish.self, forPrimaryKey: id) != nil
    }
}
