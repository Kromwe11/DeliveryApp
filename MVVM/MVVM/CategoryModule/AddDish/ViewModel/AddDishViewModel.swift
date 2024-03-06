//
//  AddDishViewModel.swift
//  MVVM
//
//  Created by Висент Щепетков on 29.02.2024.
//

import UIKit

protocol AddDishViewModelProtocol: AnyObject {
    var updateDishDetails: ((Dish, UIImage?) -> Void)? { get set }
    var presentError: ((String) -> Void)? { get set }
    func configure(dish: Dish, imageService: ImageServiceProtocol)
    func loadDishDetails()
}

final class AddDishViewModel: AddDishViewModelProtocol {
    
    // MARK: - Public properties
    var updateDishDetails: ((Dish, UIImage?) -> Void)?
    var presentError: ((String) -> Void)?
    
    // MARK: - Private properties
    private var dish: Dish?
    private var imageService: ImageServiceProtocol?
    
    // MARK: Public Methods
    func configure(dish: Dish, imageService: ImageServiceProtocol) {
        self.dish = dish
        self.imageService = imageService
    }
    
    func loadDishDetails() {
        guard let dish = dish else {
            presentError?(L10n.detailError)
            return
        }
        
        updateDishDetails?(dish, nil)
        
        if let imageURL = URL(string: dish.imageURL) {
            imageService?.loadImage(from: imageURL) { [weak self] image in
                self?.updateDishDetails?(dish, image)
            }
        }
    }
}
