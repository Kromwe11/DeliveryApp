//
//  ImageService.swift
//  TestMVP
//
//  Created by Висент Щепетков on 26.01.2024.
//

import CommonCrypto
import UIKit

/// Протокол, определяющий сервис для работы с изображениями.
protocol ImageServiceProtocol: AnyObject {
    /// Делегат, получающий уведомления об обновлениях.
    var delegate: ImageServiceDelegate? { get set }
    
    /// Загружает изображение по указанному URL.
    /// - Parameters:
    ///   - url: URL изображения для загрузки.
    ///   - completion: Блок завершения, вызываемый при завершении загрузки.
    /// - Returns: URLSessionDataTask, представляющая загрузочную задачу.
    @discardableResult
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask?
    
    /// Сохраняет изображение с указанным идентификатором.
    /// - Parameters:
    ///   - image: Изображение для сохранения.
    ///   - identifier: Идентификатор для изображения.
    ///   - completion: Блок завершения, вызываемый при завершении сохранения.
    func saveImage(_ image: UIImage, withIdentifier identifier: String)
    
    /// Загружает изображение по идентификатору.
    /// - Parameters:
    ///   - identifier: Идентификатор изображения.
    ///   - completion: Блок завершения с загруженным изображением.
    func loadImage(withIdentifier identifier: String, completion: @escaping (UIImage?) -> Void)
    
    /// Сохраняет изображение пользователя.
    /// - Parameters:
    ///   - image: Изображение пользователя для сохранения.
    func saveUserImage(_ image: UIImage)
    
    /// Загружает изображение пользователя.
    /// - Parameter completion: Блок завершения с загруженным изображением пользователя.
    func loadUserImage(completion: @escaping (UIImage?) -> Void)
    
    /// Генерирует уникальное имя файла для изображения по его URL.
    /// - Parameter url: URL изображения.
    /// - Returns: Уникальное имя файла.
    func generateFileName(from url: URL) -> String
}

/// Делегат сервиса изображений, получающий уведомления об обновлениях изображений.
protocol ImageServiceDelegate: AnyObject {
    /// Вызывается, когда изображение пользователя было обновлено.
    /// - Parameter image: Новое изображение пользователя.
    func userImageDidUpdate(_ image: UIImage)
}

final class ImageService: ImageServiceProtocol {
    
    // MARK: - Public properties
    weak var delegate: ImageServiceDelegate?
    
    // MARK: - Private properties
    private let session: URLSession = .shared
    private enum Constants {
        static let userProfileImage = "userProfileImage"
    }
    
    // MARK: - Public Methods
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        let identifier = generateFileName(from: url)

        if let cachedImage = getFromCache(withIdentifier: identifier) {
            completion(cachedImage)
            return nil
        } else {
            let task = session.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else {
                    completion(nil)
                    return
                }
                self?.saveImage(image, withIdentifier: identifier)
                completion(image)
            }
            task.resume()
            return task
        }
    }
    
    func saveImage(_ image: UIImage, withIdentifier identifier: String) {
        DispatchQueue.main.async {
            guard let data = image.pngData(),
                  let filePath = self.filePath(for: "\(identifier).png") else {
                return
            }
            _ = try? data.write(to: filePath, options: .atomic)
        }
    }
    
    func loadImage(withIdentifier identifier: String, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.main.async {
            guard let filePath = self.filePath(for: "\(identifier).png"),
                  let image = UIImage(contentsOfFile: filePath.path) else {
                completion(nil)
                return
            }
            completion(image)
        }
    }
    
    func saveUserImage(_ image: UIImage) {
        saveImage(image, withIdentifier: Constants.userProfileImage)
        self.delegate?.userImageDidUpdate(image)
    }
    
    func loadUserImage(completion: @escaping (UIImage?) -> Void) {
        loadImage(withIdentifier: Constants.userProfileImage, completion: completion)
    }
    
    func generateFileName(from url: URL) -> String {
        let urlString = url.absoluteString
        guard let data = urlString.data(using: .utf8) else { return "" }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        let hashString = hash.map { String(format: "%02x", $0) }.joined()
        return "image\(hashString).png"
    }
    
    // MARK: - Private Methods
    private func filePath(for filename: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
    }
    
    private func getFromCache(withIdentifier identifier: String) -> UIImage? {
        guard let filePath = self.filePath(for: "\(identifier).png"),
              let image = UIImage(contentsOfFile: filePath.path) 
        else { return nil }
        return image
    }
}
