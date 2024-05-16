//
//  BaseCoordinator.swift
//  DeliveryApp
//

import UIKit

/// Протокол `Coordinator` определяет интерфейс для координаторов в архитектуре приложения,
/// которые управляют навигацией и координацией между различными контроллерами представления.
protocol Coordinator: AnyObject {
    /// Список дочерних координаторов, которые управляют подконтрольными им подсекциями навигации или бизнес-логики.
    var childCoordinators: [Coordinator] { get set }
    
    /// Навигационный контроллер, который используется для управления стеком контроллеров представления.
    var navigationController: UINavigationController { get set }
    
    /// Запускает основной процесс координатора, инициализирующий начальное состояние или представление, которым он управляет.
    func start()
}

class BaseCoordinator: Coordinator {
    
    // MARK: - Public properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    // MARK: init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: Public Methods
    func start() {
    }

    func addDependency(_ coordinator: Coordinator) {
        for element in childCoordinators where element === coordinator {
            return
        }
        childCoordinators.append(coordinator)
    }

    func removeDependency(_ coordinator: Coordinator?) {
        guard let coordinator = coordinator else { return }
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }
    }
}
