//
//  СategoryViewController.swift
//  TestMVP
//
//  Created by Висент Щепетков on 25.01.2024.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    // MARK: - Public properties
    var presenter: CategoryViewPresenterProtocol!
    var imageService: ImageServiceProtocol!
    
    // MARK: - Private properties
    private var tableView: UITableView!
    private var categories: [CategoryDish] = []
    private let userImageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private enum Constants {
        static let cityError = "Местоположение не доступно"
        static let personImage = "person.fill.viewfinder"
        static let geoPoint = "geoPoint"
        static let identifier = "ru_RU"
        static let dateFormat = "d MMMM yyyy"
        static let cellIdentifier = "CategoryCell"
        static let error = "Error"
        static let ok = "Ok"
        static let accessibilityIdentifier = "CategoriesTable"
        static let unknownError = "Произошла неизвестная ошибка. Пожалуйста, попробуйте позже."
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupActivityIndicator()
        setupUserImageView()
        loadUserImage()
        presenter.getCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserImage()
    }
    
    // MARK: - Private Methods
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        userImageView.clipsToBounds = true
        userImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userImageView)
    }
    
    private func setupUserImageView() {
        userImageView.isUserInteractionEnabled = true
        userImageView.layer.cornerRadius = 18
        userImageView.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        userImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupLeftStackView(cityName: String) {
        let locationLabel = UILabel()
        locationLabel.text = cityName
        locationLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        locationLabel.textColor = .black
        
        let dateLabel = UILabel()
        dateLabel.text = dateFormatter()
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = .gray
        
        let labelsStackView = UIStackView(arrangedSubviews: [locationLabel, dateLabel])
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .fill
        
        let geoImageView = UIImageView(image: UIImage(named: Constants.geoPoint))
        geoImageView.contentMode = .scaleAspectFit
        geoImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        geoImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let leftStackView = UIStackView(arrangedSubviews: [geoImageView, labelsStackView])
        leftStackView.axis = .horizontal
        leftStackView.spacing = 8
        leftStackView.alignment = .firstBaseline
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftStackView)
    }
    
    private func dateFormatter() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Constants.identifier)
        dateFormatter.dateFormat = Constants.dateFormat
        return dateFormatter.string(from: Date())
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        
        tableView.accessibilityIdentifier = Constants.accessibilityIdentifier
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadUserImage() {
        imageService.delegate = self
        imageService.loadUserImage { [weak self] image in
            DispatchQueue.main.async {
                if let image = image {
                    self?.userImageView.image = image
                } else {
                    let systemImage = UIImage(
                        systemName: Constants.personImage)?.withTintColor(.black, renderingMode: .alwaysOriginal
                         )
                    self?.userImageView.image = systemImage
                }
            }
        }
    }
    
    // MARK: Actions
    @objc private func handleProfileImageTap() {
        selectImageFromGallery()
    }
}

// MARK: - СategoryViewProtocol
extension CategoryViewController: CategoryViewProtocol {
    
    func updateCityName(_ cityName: String) {
        DispatchQueue.main.async {
            self.setupLeftStackView(cityName: cityName)
        }
    }
    
    func displayCategories(_ categories: [CategoryDish]) {
        self.categories = categories
        guard !categories.isEmpty else {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            return
        }
        let loadImagesGroup = DispatchGroup()
        for category in categories {
            guard let url = URL(string: category.imageURL) else { continue }
            loadImagesGroup.enter()
            imageService.loadImage(from: url) { _ in
                loadImagesGroup.leave()
            }
        }
        loadImagesGroup.notify(queue: .main) {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    func displayError(_ error: Error) {
        DispatchQueue.main.async {
            let errorMessage = (error as? NetworkError)?.localizedDescription ?? Constants.unknownError
            let alert = UIAlertController(
                title: Constants.error,
                message: errorMessage,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.ok, style: .default))
            self.present(alert, animated: true)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    private func incrementLoadedImages(_ count: inout Int, total: Int) {
        count += 1
        guard count == total else { return }
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellIdentifier,
            for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let category = categories[indexPath.row]
        cell.imageService = self.imageService
        cell.configure(with: category)
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        presenter.didSelectCategory(category: category)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension CategoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func selectImageFromGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            userImageView.image = selectedImage
            imageService.saveUserImage(selectedImage)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - ImageServiceDelegate
extension CategoryViewController: ImageServiceDelegate {
    func userImageDidUpdate(_ image: UIImage) {
        userImageView.image = image
    }
}
