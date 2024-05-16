//
//  Categories.swift
//  DeliveryApp
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
    let сategories: [CategoryResponse] 
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
