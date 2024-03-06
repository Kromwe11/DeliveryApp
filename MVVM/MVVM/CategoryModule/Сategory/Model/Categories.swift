//
//  Categories.swift
//  TestMVP
//
//  Created by Висент Щепетков on 25.01.2024.
//

import Foundation
import RealmSwift

final class CategoryDish: Object, Decodable {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var imageURL: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

struct CategoriesResponse: Decodable {
    let categories: [CategoryResponse]

    enum CodingKeys: String, CodingKey {
        case categories = "сategories"
    }
}

struct CategoryResponse: Decodable {
    let id: Int
    let name: String
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageURL = "image_url"
    }
}
