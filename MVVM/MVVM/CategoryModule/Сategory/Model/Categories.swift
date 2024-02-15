//
//  Categories.swift
//  TestMVP
//
//  Created by Висент Щепетков on 25.01.2024.
//

import Foundation

/// Сategories
struct Сategories: Decodable {
    let сategories: [CategoryDish]
}

/// Сategory
struct CategoryDish: Decodable, Equatable {
    let id: Int
    let name: String
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageURL = "image_url"
    }
}
