//
//  SceneDelegate.swift
//  TestTestMVVM
//
//  Created by Висент Щепетков on 25.01.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        guard 
            let appDelegate = UIApplication.shared.delegate as? AppDelegate 
        else { return }
        let coreDataStorageManager = CoreDataStorageManager(container: appDelegate.persistentContainer)
        let networkManager = NetworkManager()
        let imageService = ImageService()

        let categoryModuleAssembly = CategoryModuleAssembly(
            imageService: imageService,
            coreDataStorageManager: coreDataStorageManager,
            networkManager: networkManager)
        let dishModuleAssembly = DishModuleAssembly(
            imageService: imageService,
            coreDataStorageManager: coreDataStorageManager,
            networkManager: networkManager)
        let addDishModuleAssembly = AddDishModuleAssembly(
            imageService: imageService,
            coreDataStorageManager: coreDataStorageManager)

        let tabBarController = TabBarController()
        tabBarController.configure(
            categoryModuleAssembly: categoryModuleAssembly,
            dishModuleAssembly: dishModuleAssembly,
            addDishModuleAssembly: addDishModuleAssembly
        )

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}
