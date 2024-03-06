//
//  SceneDelegate.swift
//  TestTestMVVM
//
//  Created by Висент Щепетков on 25.01.2024.
//

import RealmSwift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var categoryCoordinator: CategoryCoordinator?
    var tabBarController: TabBarController?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let realmStorageManager = RealmStorageManager()
        let networkManager = NetworkManager()
        let imageService = ImageService()

        let navigationController = UINavigationController()
        
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

        let addDishModuleAssembly = AddDishModuleAssembly(
            imageService: imageService
        )

        categoryCoordinator = CategoryCoordinator(
            navigationController: navigationController,
            assembly: categoryModuleAssembly,
            dishAssembly: dishModuleAssembly,
            addDishAssembly: addDishModuleAssembly
        )
        
        let tabBarController = TabBarController()
        tabBarController.configure(categoryCoordinator: categoryCoordinator!)
        self.tabBarController = tabBarController
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}
