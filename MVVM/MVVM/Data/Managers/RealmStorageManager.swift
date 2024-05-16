//
//  RealmStorageManager.swift
//  DeliveryApp
//

import Foundation
import RealmSwift

/// `RealmManaging` определяет интерфейс для управления данными, хранящимися в базе данных Realm.
/// Этот протокол обеспечивает основные функции для сохранения, извлечения и проверки существования объектов в базе данных.
protocol RealmManaging {
    /// Сохраняет массив объектов в базе данных Realm.
    /// - Parameter objects: Массив объектов `Object` для сохранения. Объекты должны быть наследниками `Object` из Realm.
    func saveObjects<T: Object>(_ objects: [T])
    
    /// Извлекает все объекты заданного типа из базы данных Realm.
    /// - Parameter type: Тип объектов, которые необходимо извлечь. Тип должен быть наследником `Object`.
    /// - Returns: Массив объектов заданного типа.
    func fetchObjects<T: Object>(_ type: T.Type) -> [T]
    
    /// Проверяет, существует ли объект указанного типа с заданным первичным ключом.
    /// - Parameters:
    ///   - type: Тип объекта, проверку существования которого необходимо выполнить.
    ///   - id: Первичный ключ объекта для проверки. Должен быть совместим с `AnyHashable`.
    /// - Returns: `true`, если объект существует в базе данных; в противном случае, `false`.
    func objectExists<T: Object>(_ type: T.Type, withID id: AnyHashable) -> Bool
}

final class RealmStorageManager: RealmManaging {
    // MARK: - Private properties
    private let realm: Realm
    
    // MARK: init
    init(realm: Realm) {
        self.realm = realm
    }
    
    // MARK: Public Methods
    func saveObjects<T: Object>(_ objects: [T]) {
        try? realm.write {
            realm.add(objects, update: .modified)
        }
    }
    
    func fetchObjects<T: Object>(_ type: T.Type) -> [T] {
        Array(realm.objects(type))
    }
    
    func objectExists<T: Object>(_ type: T.Type, withID id: AnyHashable) -> Bool {
        realm.object(ofType: type, forPrimaryKey: id) != nil
    }
}
