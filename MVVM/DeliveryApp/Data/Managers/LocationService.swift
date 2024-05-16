//
//  LocationService.swift
//  DeliveryApp
//

import CoreLocation
import Foundation
import Network

/// Протокол `LocationServiceProtocol` определяет интерфейс для службы, которая управляет
/// получением и обновлением геолокационных данных устройства.
protocol LocationServiceProtocol {
    /// Делегат, отвечающий за обработку обновлений местоположения и ошибок.
    var delegate: LocationServiceDelegate? { get set }
    
    /// Начинает процесс мониторинга изменений геолокации.
    func startUpdatingLocation()
    
    /// Останавливает мониторинг изменений геолокации.
    func stopUpdatingLocation()
}

/// Протокол `LocationServiceDelegate` предоставляет методы для обработки событий,
/// связанных с изменениями местоположения и ошибками при их получении.
protocol LocationServiceDelegate: AnyObject {
    /// Вызывается, когда обновляется местоположение устройства.
    /// - Parameter locations: Массив новых местоположений.
    func didUpdateLocations(_ locations: [CLLocation])
    
    /// Вызывается при возникновении ошибки в процессе получения геолокации.
    /// - Parameter error: Ошибка, возникшая при попытке получить местоположение.
    func didFailWithError(_ error: Error)
}

final class LocationService: NSObject, LocationServiceProtocol {
    
    // MARK: - Public properties
    weak var delegate: LocationServiceDelegate?
    
    // MARK: - Private properties
    private let locationManager: CLLocationManager
    private let networkMonitor: NWPathMonitor
    
    // MARK: - init
    init(
        locationManager: CLLocationManager = CLLocationManager(),
        networkMonitor: NWPathMonitor = NWPathMonitor()
    ) {
        self.locationManager = locationManager
        self.networkMonitor = networkMonitor
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: Public Methods
    func startUpdatingLocation() {
        setupNetworkMonitoring()
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
                    self?.delegate?.didFailWithError(LocationError.noInternetAccess)
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitoring")
        networkMonitor.start(queue: queue)
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            delegate?.didFailWithError(LocationError.locationDenied)
        default:
            locationManager.startUpdatingLocation()
        }
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
}
