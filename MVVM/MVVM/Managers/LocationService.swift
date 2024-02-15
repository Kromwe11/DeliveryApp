// LocationService.swift
// TestMVP
//
// Created by Висент Щепетков on 13.02.2024.

import CoreLocation
import Foundation
import Network

/// Протокол для службы местоположения, управляющей обновлениями местоположения.
protocol LocationServiceProtocol {
    /// Делегат, получающий уведомления об обновлениях местоположения и ошибках.
    var delegate: LocationServiceDelegate? { get set }
    
    /// Начинает обновление местоположения пользователя.
    func startUpdatingLocation()
    
    /// Останавливает обновление местоположения пользователя.
    func stopUpdatingLocation()
}

/// Делегат, получающий уведомления от службы местоположения.
protocol LocationServiceDelegate: AnyObject {
    /// Вызывается при обновлении местоположений.
    /// - Parameter locations: Массив обновлённых местоположений.
    func didUpdateLocations(_ locations: [CLLocation])
    
    /// Вызывается при возникновении ошибки при получении местоположения.
    /// - Parameter error: Ошибка, возникшая при обновлении местоположения.
    func didFailWithError(_ error: Error)
}

final class LocationService: NSObject, LocationServiceProtocol {
    // MARK: - Public properties
    weak var delegate: LocationServiceDelegate?
    
    // MARK: - Private properties
    private let locationManager: CLLocationManager
    private let networkMonitor: NWPathMonitor
    private enum Constants {
        static let locationService = "LocationService"
        static let noInternetAccess = "Нет доступа к интернету"
        static let locationDenied = "Нет доступа к геопозиции"
        static let networkMonitoring = "NetworkMonitoring"
    }
    
    // MARK: - init
    override init() {
        locationManager = CLLocationManager()
        networkMonitor = NWPathMonitor()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        setupNetworkMonitoring()
    }
    
    // MARK: - Public Methods
    func startUpdatingLocation() {
        checkLocationAuthorization()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Private Methods
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.locationManager.startUpdatingLocation()
                } else {
                    let error = NSError(
                        domain: Constants.locationService,
                        code: 2,
                        userInfo: [NSLocalizedDescriptionKey: Constants.noInternetAccess]
                    )
                    self?.delegate?.didFailWithError(error)
                }
            }
        }
        
        let queue = DispatchQueue(label: Constants.networkMonitoring)
        networkMonitor.start(queue: queue)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.didUpdateLocations(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    private func checkLocationAuthorization() {
        if locationManager.authorizationStatus == .denied
           || locationManager.authorizationStatus == .restricted
           || locationManager.authorizationStatus == .notDetermined {
            let error = NSError(
                domain: Constants.locationService,
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: Constants.locationDenied])
            delegate?.didFailWithError(error)
        }
    }
}
