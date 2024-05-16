//
//  AddDishViewModel.swift
//  DeliveryApp
//

import UIKit

/// `AddDishViewModelProtocol` определяет интерфейс для ViewModel, который управляет логикой добавления или редактирования блюда.
///
/// Этот протокол предоставляет методы и свойства, необходимые для конфигурации ViewModel с данными о блюде,
/// загрузки деталей блюда, и уведомления View о необходимости обновления интерфейса или отображения ошибок.
protocol AddDishViewModelProtocol: AnyObject {
    /// Коллбэк для обновления деталей блюда в View. Передает `Dish` и возможно изображение, если оно загружено.
    var updateDishDetails: ((Dish, UIImage?) -> Void)? { get set }
    
    /// Коллбэк для отображения предупреждающих сообщений пользователю.
    var presentAlert: ((String) -> Void)? { get set }
    
    /// Конфигурирует ViewModel данными о блюде и сервисом для работы с изображениями.
    /// - Parameters:
    ///   - dish: Объект `Dish`, содержащий информацию о блюде.
    ///   - imageService: Сервис для загрузки и обработки изображений.
    func configure(dish: Dish, imageService: ImageServiceProtocol)
    
    /// Загружает детали о блюде, включая запрос на загрузку изображения, если URL доступен.
    /// Вызывает `updateDishDetails` для обновления UI и может вызвать `presentAlert`, если возникнут ошибки.
    func loadDishDetails()
}

final class AddDishViewModel: AddDishViewModelProtocol {
    
    // MARK: - Public properties
    var updateDishDetails: ((Dish, UIImage?) -> Void)?
    var presentAlert: ((String) -> Void)?
    
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
            presentAlert?(L10n.detailError)
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
