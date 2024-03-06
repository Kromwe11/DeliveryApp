//
//  DishModel.swift
//  TestMVP
//
//  Created by Висент Щепетков on 26.01.2024.
//

import Foundation
import RealmSwift

final class Dish: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var price: Int = 0
    @objc dynamic var weight: Int = 0
    @objc dynamic var dishDescription: String = ""
    @objc dynamic var imageURL: String = ""
    var tegs = List<String>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum Teg: String, CaseIterable {
        case allMenu = "Все меню"
        case salad = "Салаты"
        case ris = "С рисом"
        case fish = "С рыбой"
        
        static func stringValues() -> [String] {
            return Teg.allCases.map { $0.rawValue }
        }
    }
}

struct DishesResponse: Decodable {
    let dishes: [DishResponse]
}

struct DishResponse: Decodable {
    let id: Int
    let name: String
    let price: Int
    let weight: Int
    let description: String
    let imageURL: String
    let tegs: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case weight
        case description
        case imageURL = "image_url"
        case tegs
    }
}
