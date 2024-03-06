//
//  CategoryViewModel.swift
//  MVVM
//
//  Created by Висент Щепетков on 23.02.2024.
//

import CoreLocation
import Foundation
import Network

protocol CategoryViewModelProtocol: AnyObject {
    var updateData: (() -> ())? { get set }
    var presentError: ((String) -> Void)? { get set }
    var updateCityName: ((String) -> Void)? { get set }
    var categories: [CategoryDish] { get }
    func getCategories()
    func didSelectCategory(category: CategoryDish?)
}

final class CategoryViewModel: CategoryViewModelProtocol, LocationServiceDelegate {
    // MARK: - Public properties
    var updateData: (() -> ())?
    var presentError: ((String) -> Void)?
    var updateCityName: ((String) -> Void)?
    var categories: [CategoryDish] = []
    weak var coordinator: CategoryCoordinator?
    
    // MARK: - Private properties
    private var networkManager: NetworkManagerProtocol?
    private var realmStorageManager: RealmManaging?
    private var locationService: LocationServiceProtocol?
    private let networkMonitor = NWPathMonitor()
    private var isNetworkAvailable: Bool = false
    
    // MARK: Public Methods
    func configure(
        networkManager: NetworkManagerProtocol,
        realmStorageManager: RealmManaging,
        locationService: LocationServiceProtocol,
        coordinator: CategoryCoordinator
    ) {
        self.networkManager = networkManager
        self.realmStorageManager = realmStorageManager
        self.locationService = locationService
        self.coordinator = coordinator
        
        self.locationService?.delegate = self
        startNetworkMonitoring()
        getCategories()
    }

    func getCategories() {
        if isNetworkAvailable {
            networkManager?.fetchCategories { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let categoryResponses):
                        let categories = categoryResponses.map {
                            CategoryDish(value: ["id": $0.id, "name": $0.name, "imageURL": $0.imageURL])
                        }
                        categories.forEach { category in
                            self?.realmStorageManager?.saveCategory(category, completion: { error in
                                if let error = error {
                                    print("Ошибка сохранения категории в Realm: \(error)")
                                }
                            })
                        }
                        self?.categories = categories
                        self?.updateData?()
                    case .failure(let error):
                        self?.presentError?(error.localizedDescription)
                    }
                }
            }
        } else {
            if let cachedCategories = self.realmStorageManager?.fetchCategories(), !cachedCategories.isEmpty {
                self.categories = cachedCategories
                self.updateData?()
            } else {
                self.presentError?(L10n.networkError)
            }
        }
    }

    
    func didSelectCategory(category: CategoryDish?) {
        guard let category = category else { return }
        coordinator?.showDishList(for: category)
    }

    func didUpdateLocations(_ locations: [CLLocation]) {
        guard let location = locations.first else { return }
        lookUpCurrentLocation(location: location)
    }
    
    func didFailWithError(_ error: Error) {
        updateCityName?("\(error.localizedDescription)")
    }

    // MARK: Private Methods
    private func lookUpCurrentLocation(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            if let placemarks = placemarks, let placemark = placemarks.first, let city = placemark.locality {
                self?.updateCityName?(city)
            } else {
                self?.updateCityName?(L10n.cityError)
            }
        }
    }
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
                if self?.isNetworkAvailable == true {
                    self?.getCategories()
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
    }
}
