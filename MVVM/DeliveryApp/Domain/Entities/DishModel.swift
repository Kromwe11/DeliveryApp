//
//  DishModel.swift
//  DeliveryApp
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
    
    convenience init(from dishResponse: DishResponse) {
        self.init()
        self.id = dishResponse.id
        self.name = dishResponse.name
        self.price = dishResponse.price
        self.weight = dishResponse.weight
        self.dishDescription = dishResponse.description
        self.imageURL = dishResponse.imageURL
        self.tegs.append(objectsIn: dishResponse.tegs)
    }
    
    enum Tag: CaseIterable {
        case allMenu
        case salad
        case rice
        case fish
        
        var localized: String {
            switch self {
            case .allMenu:
                return L10n.allMenu
            case .salad:
                return L10n.salad
            case .rice:
                return L10n.rice
            case .fish:
                return L10n.fish
            }
        }
        
        static func stringValues() -> [String] {
            return Tag.allCases.map { $0.localized }
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
