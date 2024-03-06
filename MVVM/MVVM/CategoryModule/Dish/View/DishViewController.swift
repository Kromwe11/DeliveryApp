//
//  DishViewController.swift
//  TestMVP
//
//  Created by Висент Щепетков on 26.01.2024.
//

import UIKit

final class DishViewController: UIViewController {
    
    // MARK: - Public properties
    var viewModel: DishViewModelProtocol!
    var imageService: ImageServiceProtocol!
    var coordinator: DishCoordinator?
    
    // MARK: - Private properties
    private var dishesCollectionView: UICollectionView!
    private var filtersCollectionView: UICollectionView!
    private var selectedFilterIndex = 0
    
    private enum Constants {
        static let personImage = "person.fill.viewfinder"
        static let categoryIdentify = "DishCategoryButtonCell"
        static let dishIdentify = "DishCell"
        static let accessibilityIdentifier = "DishesCollection"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupFiltersCollectionView()
        setupDishesCollectionView()
        bindViewModel()
        viewModel.fetchDishes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserImage()
    }
    
    // MARK: - Override Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let initialSelectionIndexPath = IndexPath(item: selectedFilterIndex, section: 0)
        filtersCollectionView.selectItem(
            at: initialSelectionIndexPath,
            animated: false,
            scrollPosition: [])
    }
    
    func configure(
        viewModel: DishViewModelProtocol,
        imageService: ImageServiceProtocol,
        coordinator: DishCoordinator?
    ) {
        self.viewModel = viewModel
        self.imageService = imageService
        self.coordinator = coordinator
    }
    
    // MARK: - Private Methods
    private func bindViewModel() {
        viewModel.updateData = { [weak self] in
            DispatchQueue.main.async {
                self?.dishesCollectionView.reloadData()
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
    }
    
    private func setupNavigationBar() {
        title = viewModel.categoryName
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        
        setupRightUserImageView()
    }
    
    private func setupRightUserImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleUserImageTap))
        let rightUserImageView = UIImageView()
        rightUserImageView.isUserInteractionEnabled = true
        rightUserImageView.addGestureRecognizer(tapGesture)
        rightUserImageView.contentMode = .scaleAspectFill
        rightUserImageView.layer.cornerRadius = 18
        rightUserImageView.clipsToBounds = true
        rightUserImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        rightUserImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightUserImageView)
        loadUserImage()
    }
    
    private func loadUserImage() {
        imageService.delegate = self
        imageService.loadUserImage { [weak self] image in
            DispatchQueue.main.async {
                guard let imageView = self?.navigationItem.rightBarButtonItem?.customView as? UIImageView 
                else { return }
                if let image = image {
                    imageView.image = image
                } else {
                    let systemImage = UIImage(
                        systemName: Constants.personImage)?.withTintColor(.black, renderingMode: .alwaysOriginal
                        )
                    imageView.image = systemImage
                }
            }
        }
    }
    
    private func setupFiltersCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        filtersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        filtersCollectionView.backgroundColor = .white
        filtersCollectionView.register(
            DishCategoryButtonCell.self,
            forCellWithReuseIdentifier: Constants.categoryIdentify)
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self
        
        filtersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filtersCollectionView)
        
        NSLayoutConstraint.activate([
            filtersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filtersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filtersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filtersCollectionView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupDishesCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        dishesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        dishesCollectionView.backgroundColor = .white
        dishesCollectionView.register(DishCell.self, forCellWithReuseIdentifier: Constants.dishIdentify)
        dishesCollectionView.delegate = self
        dishesCollectionView.dataSource = self
        
        dishesCollectionView.accessibilityIdentifier = Constants.accessibilityIdentifier
        
        dishesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dishesCollectionView)
        
        NSLayoutConstraint.activate([
            dishesCollectionView.topAnchor.constraint(
                equalTo: filtersCollectionView.bottomAnchor,
                constant: 10
            ),
            dishesCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            dishesCollectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            dishesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func handleUserImageTap() {
        selectImageFromGallery()
    }
}

// MARK: - UICollectionViewDataSource
extension DishViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == filtersCollectionView {
            return Dish.Teg.stringValues().count
        } else {
            return viewModel.dishes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == filtersCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.categoryIdentify, for: indexPath) as? DishCategoryButtonCell else {
                return UICollectionViewCell()
            }
            let tagValue = Dish.Teg.stringValues()[indexPath.item]
            cell.configure(with: tagValue)
            cell.isSelected = indexPath.item == selectedFilterIndex
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.dishIdentify, for: indexPath) as? DishCell else {
                return UICollectionViewCell()
            }
            let dish = viewModel.dishes[indexPath.row]
            cell.configure(with: dish)
            return cell
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension DishViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
            guard collectionView == self.filtersCollectionView else {
                let padding: CGFloat = 16
                let availableWidth = collectionView.frame.width - (padding * 3)
                let widthPerItem = availableWidth / 3
                return CGSize(width: widthPerItem, height: widthPerItem + 40)
            }
            return CGSize(width: 90, height: 33)
        }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10
    }
}

// MARK: - UICollectionViewDelegate
extension DishViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dishesCollectionView {
            let selectedDish = viewModel.dishes[indexPath.row]
            coordinator?.showAddDishScreen(dish: selectedDish)
        } else if collectionView == filtersCollectionView {
            selectedFilterIndex = indexPath.item
            let selectedTag = Dish.Teg.stringValues()[indexPath.item]
            viewModel.filterDishes(by: selectedTag)
            filtersCollectionView.reloadData()
            dishesCollectionView.reloadData()
            filtersCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension DishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                imageService.saveUserImage(selectedImage)
                loadUserImage() 
            }
            picker.dismiss(animated: true)
        }
}

// MARK: - ImageServiceDelegate
extension DishViewController: ImageServiceDelegate {
    func userImageDidUpdate(_ image: UIImage) {
        DispatchQueue.main.async {
            guard 
                let imageView = self.navigationItem.rightBarButtonItem?.customView as? UIImageView 
            else { return }
            imageView.image = image
        }
    }
}
