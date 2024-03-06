//
//  СategoryViewController.swift
//  TestMVP
//
//  Created by Висент Щепетков on 25.01.2024.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    // MARK: - Public properties
    var imageService: ImageServiceProtocol!
    var viewModel: CategoryViewModelProtocol!
    
    // MARK: - Private properties
    private var tableView: UITableView!
    private var categories: [CategoryDish] = []
    private let userImageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private enum Constants {
        static let personImage = "person.fill.viewfinder"
        static let geoPoint = "geoPoint"
        static let identifier = "ru_RU"
        static let dateFormat = "d MMMM yyyy"
        static let cellIdentifier = "CategoryCell"
        static let error = "Error"
        static let ok = "Ok"
        static let accessibilityIdentifier = "CategoriesTable"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupActivityIndicator()
        setupUserImageView()
        loadUserImage()
        bindViewModel()
        viewModel.getCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserImage()
    }
    
    func configure(viewModel: CategoryViewModelProtocol, imageService: ImageServiceProtocol) {
        self.viewModel = viewModel
        self.imageService = imageService
    }
    
    // MARK: - Private Methods
    private func bindViewModel() {
        viewModel.updateData = { [weak self] in
            DispatchQueue.main.async {
                self?.categories = self?.viewModel.categories ?? []
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.presentError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                let alertController = UIAlertController(
                    title: Constants.error,
                    message: errorMessage,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: Constants.ok, style: .default))
                self?.present(alertController, animated: true)
            }
        }
        
        viewModel.updateCityName = { [weak self] cityName in
            DispatchQueue.main.async {
                self?.setupLeftStackView(cityName: cityName)
            }
        }
    }
    
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

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellIdentifier,
            for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.categories[indexPath.row]
        cell.imageService = self.imageService
        cell.configure(with: category)
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.categories[indexPath.row]
        viewModel.didSelectCategory(category: category)
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
