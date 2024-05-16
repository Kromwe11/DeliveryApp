//
//  ApplicationCoordinator.swift
//  MVVM
//
//  Created by Висент Щепетков on 14.03.2024.
//

import RealmSwift
import UIKit

final class ApplicationCoordinator: BaseCoordinator {
    // MARK: - Private properties
    private var window: UIWindow
    private var networkMonitorService: NetworkMonitorServiceProtocol?
    
    // MARK: - init
    init(window: UIWindow, navigationController: UINavigationController) {
        self.window = window
        super.init(navigationController: navigationController)
    }

    // MARK: - Override Methods
    override func start() {
        let realm = try? Realm()
        guard let safeRealm = realm else { return }

        let realmStorageManager = RealmStorageManager(realm: safeRealm)
        let networkManager = NetworkManager()
        let imageService = ImageService()
        networkMonitorService = NetworkMonitorService()
        networkMonitorService?.startMonitoring()

        let categoryModuleAssembly = CategoryModuleAssembly(
            imageService: imageService,
            realmStorageManager: realmStorageManager,
            networkManager: networkManager
        )
        let dishModuleAssembly = DishModuleAssembly(
            imageService: imageService,
            realmStorageManager: realmStorageManager,
            networkManager: networkManager
        )
        let addDishModuleAssembly = AddDishModuleAssembly(imageService: imageService)
        let categoryCoordinator = CategoryCoordinator(
            navigationController: UINavigationController(),
            assembly: categoryModuleAssembly,
            dishAssembly: dishModuleAssembly,
            addDishAssembly: addDishModuleAssembly
        )

        let tabBarController = TabBarController()
        tabBarController.configure(categoryCoordinator: categoryCoordinator)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        categoryCoordinator.start()
    }
}
