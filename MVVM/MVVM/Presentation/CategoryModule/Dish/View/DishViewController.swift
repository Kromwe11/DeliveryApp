//
//  DishViewController.swift
//  DeliveryApp
//

import UIKit

final class DishViewController: UIViewController {
    
    // MARK: - Public properties
    var viewModel: DishViewModelProtocol!
    var imageService: ImageServiceProtocol!
    var coordinator: DishCoordinator?
    
    // MARK: - Private properties
    private var collectionView: UICollectionView!
    private var selectedFilterIndex = 0
    
    private enum Section: Int, CaseIterable {
        case filters
        case dishes
    }
    
    private enum Constants {
        static let personImage = "person.fill.viewfinder"
        static let categoryCellIdentifier = "DishCategoryButtonCell"
        static let dishCellIdentifier = "DishCell"
        static let accessibilityIdentifier = "DishesCollection"
        static let error = "Error"
        static let ok = "OK"
        static let filterHeight: CGFloat = 44
        static let sectionInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        static let itemsPerRow: CGFloat = 3
        static let interItemSpacing: CGFloat = 10
        static let lineSpacing: CGFloat = 10
        static let filterItemsVisiblePortion: CGFloat = 3.5
        static let filterItemHorizontalPadding: CGFloat = 15
        static let filterSectionEndPadding: CGFloat = 10
        static let dishItemAspectRatio: CGFloat = 4.0 / 3.0
        static let userImageViewSize: CGFloat = 36
        static let userImageViewCornerRadius: CGFloat = 18
        static let filterSectionTopInset: CGFloat = 5
        static let filterButtonWidth: CGFloat = 90
    }


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        bindViewModel()
        viewModel.fetchDishes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserImage()
    }
    
    // MARK: - Public Methods
    func configure(viewModel: DishViewModelProtocol, imageService: ImageServiceProtocol, coordinator: DishCoordinator?) {
        self.viewModel = viewModel
        self.imageService = imageService
        self.coordinator = coordinator
    }
    
    // MARK: - Private Methods
    private func bindViewModel() {
        viewModel.updateData = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                let selectedIndexPath = IndexPath(item: self?.selectedFilterIndex ?? 0, section: Section.filters.rawValue)
                self?.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
            }
        }

        viewModel.presentAlert = { [weak self] errorMessage in
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: Constants.error, message: errorMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: Constants.ok, style: .default))
                self?.present(alertController, animated: true)
            }
        }
    }
    
    private func setupNavigationBar() {
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        setupRightUserImageView()
    }
    
    private func setupRightUserImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleUserImageTap))
        let rightUserImageView = UIImageView()
        rightUserImageView.isUserInteractionEnabled = true
        rightUserImageView.addGestureRecognizer(tapGesture)
        rightUserImageView.contentMode = .scaleAspectFill
        rightUserImageView.layer.cornerRadius = Constants.userImageViewCornerRadius
        rightUserImageView.clipsToBounds = true
        rightUserImageView.widthAnchor.constraint(equalToConstant: Constants.userImageViewSize).isActive = true
        rightUserImageView.heightAnchor.constraint(equalToConstant: Constants.userImageViewSize).isActive = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightUserImageView)
        loadUserImage()
    }
    
    private func loadUserImage() {
        imageService.loadUserImage { [weak self] image in
            DispatchQueue.main.async {
                guard let imageView = self?.navigationItem.rightBarButtonItem?.customView as? UIImageView else { return }
                imageView.image = image ?? UIImage(systemName: Constants.personImage)?.withTintColor(.black, renderingMode: .alwaysOriginal)
            }
        }
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(DishCategoryButtonCell.self, forCellWithReuseIdentifier: Constants.categoryCellIdentifier)
        collectionView.register(DishCell.self, forCellWithReuseIdentifier: Constants.dishCellIdentifier)
        
        view.addSubview(collectionView)
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            guard let sectionType = Section(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .filters:
                return self.createFiltersSectionLayout()
            case .dishes:
                return self.createDishesSectionLayout()
            }
        }
    }
    
    private func createFiltersSectionLayout() -> NSCollectionLayoutSection {
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth / Constants.filterItemsVisiblePortion) - Constants.filterItemHorizontalPadding
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(Constants.filterHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 5,
            leading: Constants.filterSectionEndPadding,
            bottom: 0,
            trailing: Constants.filterSectionEndPadding)
        section.interGroupSpacing = Constants.filterSectionEndPadding

        return section
    }

    private func createDishesSectionLayout() -> NSCollectionLayoutSection {
        let paddingSpace = Constants.interItemSpacing * (Constants.itemsPerRow + 1)
        let availableWidth = UIScreen.main.bounds.width - paddingSpace
        let dishItemWidth = availableWidth / Constants.itemsPerRow
        let dishItemHeight = dishItemWidth * Constants.dishItemAspectRatio

        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(dishItemWidth),
                                              heightDimension: .absolute(dishItemHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: Constants.interItemSpacing / 2,
                                                     leading: Constants.interItemSpacing / 2,
                                                     bottom: Constants.interItemSpacing / 2,
                                                     trailing: Constants.interItemSpacing / 2)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(dishItemHeight))
        
        let group = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { environment -> [NSCollectionLayoutGroupCustomItem] in
            var customItems = [NSCollectionLayoutGroupCustomItem]()
            for i in 0..<Int(Constants.itemsPerRow) {
                let frame = CGRect(x: (dishItemWidth + Constants.interItemSpacing) * CGFloat(i),
                                   y: 0,
                                   width: dishItemWidth,
                                   height: dishItemHeight)
                let customItem = NSCollectionLayoutGroupCustomItem(frame: frame)
                customItems.append(customItem)
            }
            return customItems
        }

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = Constants.sectionInsets
        section.interGroupSpacing = Constants.lineSpacing

        return section
    }
    
    // MARK: - Action
    @objc private func handleUserImageTap() {
        selectImageFromGallery()
    }
}

// MARK: - UICollectionViewDataSource
extension DishViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .filters:
            return Dish.Tag.stringValues().count
        case .dishes:
            return viewModel.getDishes().count
        case .none:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .filters:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.categoryCellIdentifier, for: indexPath) as? DishCategoryButtonCell else {
                return UICollectionViewCell()
            }
            let tagValue = Dish.Tag.stringValues()[indexPath.item]
            cell.configure(with: tagValue)
            cell.isSelected = indexPath.item == selectedFilterIndex
            return cell
        case .dishes:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.dishCellIdentifier, for: indexPath) as? DishCell else {
                return UICollectionViewCell()
            }
            let dish = viewModel.getDishes()[indexPath.row]
            cell.imageService = imageService
            cell.configure(with: dish)
            return cell
        case .none:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension DishViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .filters:
            selectedFilterIndex = indexPath.item
            let selectedTag = Dish.Tag.stringValues()[indexPath.item]
            viewModel.filterDishes(by: selectedTag)
            collectionView.reloadData()
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        case .dishes:
            let selectedDish = viewModel.getDishes()[indexPath.row]
            coordinator?.showAddDishScreen(dish: selectedDish)
        case .none:
            break
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DishViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionType = Section(rawValue: indexPath.section)
        switch sectionType {
        case .filters:
            return CGSize(width: Constants.filterButtonWidth, height: Constants.filterHeight)
        case .dishes:
            let paddingSpace = Constants.interItemSpacing * (Constants.itemsPerRow + 1)
            let availableWidth = collectionView.frame.width - paddingSpace
            let widthPerItem = availableWidth / Constants.itemsPerRow
            let heightPerItem = widthPerItem * Constants.dishItemAspectRatio
            return CGSize(width: widthPerItem, height: heightPerItem)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = Constants.sectionInsets
        return UIEdgeInsets(top: insets.top, left: insets.leading, bottom: insets.bottom, right: insets.trailing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.interItemSpacing
    }
}


// MARK: - UIImagePickerControllerDelegate
extension DishViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageService.saveUserImage(selectedImage)
            loadUserImage()
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate
extension DishViewController: UINavigationControllerDelegate {
    private func selectImageFromGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
}
