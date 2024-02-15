//
//  DishModel.swift
//  TestMVP
//
//  Created by Висент Щепетков on 26.01.2024.
//

import Foundation

/// Dishes
struct Dishes: Decodable {
    let dishes: [Dish]
}

/// Dish
struct Dish: Decodable, Equatable {
    let id: Int
    let name: String
    let price: Int
    let weight: Int
    let dishDescription: String
    let imageURL: String
    let tegs: [Teg]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case weight
        case dishDescription = "description"
        case imageURL = "image_url"
        case tegs
    }
    
    enum Teg: String, Decodable, CaseIterable {
        case allMenu = "Все меню"
        case salad = "Салаты"
        case ris = "С рисом"
        case fish = "С рыбой"
    }
}
