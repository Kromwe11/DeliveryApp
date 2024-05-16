//
//  NetworkMonitorService.swift
//  MVVM
//
//  Created by Висент Щепетков on 11.03.2024.
//

import Network

/// `NetworkMonitorServiceProtocol` определяет интерфейс для службы, которая отслеживает состояние сетевого соединения.
/// Этот протокол предоставляет методы для начала мониторинга сети и проверки её доступности.
protocol NetworkMonitorServiceProtocol {
    /// Предоставляет текущее состояние доступности сети.
    var isNetworkAvailable: Bool { get }
    
    /// Начинает мониторинг изменений состояния сетевого соединения.
    func startMonitoring()
    
    /// Выполняет проверку текущего состояния сетевого соединения и возвращает результат в асинхронном коллбэке.
    /// - Parameter completion: Коллбэк, который вызывается с результатом проверки (true, если сеть доступна).
    func checkNetworkAvailability(completion: @escaping (Bool) -> Void)
}

final class NetworkMonitorService: NetworkMonitorServiceProtocol {
    
    // MARK: - Public properties
    private var networkMonitor: NWPathMonitor?
    
    // MARK: - Private properties
    var isNetworkAvailable: Bool = false
    
    // MARK: - Public Methods
    func startMonitoring() {
        networkMonitor = NWPathMonitor()
        networkMonitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor?.start(queue: queue)
    }
    
    func checkNetworkAvailability(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async { [weak self] in
            completion(self?.isNetworkAvailable ?? false)
        }
    }
    
}
