//
//  AddDishModuleAssembly.swift
//  DeliveryApp 
//

import UIKit

/// `AddDishModuleAssemblyProtocol` определяет интерфейс для сборочного модуля,
/// который создает экземпляры `UIViewController` для добавления или редактирования блюда.
protocol AddDishModuleAssemblyProtocol {
    /// Создает `UIViewController`, который используется для управления представлением добавления или редактирования блюда.
    /// Этот метод отвечает за создание и конфигурацию `UIViewController`, который интегрируется
    /// с `AddDishCoordinator` для обработки логики добавления или изменения блюда в приложении.
    /// Контроллер представления настроен с помощью соответствующей `ViewModel`, которая управляет
    /// данными и взаимодействиями пользователя.
    ///
    /// - Parameters:
    ///   - dish: Объект `Dish`, который содержит данные о блюде, которое добавляется или редактируется.
    ///   - coordinator: Координатор, который управляет процессом добавления или редактирования блюда.
    func createModule(dish: Dish, coordinator: AddDishCoordinator) -> UIViewController
}

final class AddDishModuleAssembly: AddDishModuleAssemblyProtocol {
    // MARK: - Private properties
    private let imageService: ImageServiceProtocol
    
    // MARK: - init
    init(imageService: ImageServiceProtocol) {
        self.imageService = imageService
    }
    
    // MARK: - Public Methods
    func createModule(dish: Dish, coordinator: AddDishCoordinator) -> UIViewController {
        let viewModel = AddDishViewModel()
        viewModel.configure(dish: dish, imageService: imageService)

        let view = AddDishViewController()
        view.configure(viewModel: viewModel)

        return view
    }
}
