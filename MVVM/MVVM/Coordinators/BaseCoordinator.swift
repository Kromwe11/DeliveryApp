//
//  BaseCoordinator.swift
//  MVVM
//
//  Created by Висент Щепетков on 21.02.2024.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}

/// BaseCoordinator
class BaseCoordinator: Coordinator {
    
    // MARK: - Private properties
    var navigationController: UINavigationController
    
    // MARK: init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: Public Methods
    func start() {
    }
}
