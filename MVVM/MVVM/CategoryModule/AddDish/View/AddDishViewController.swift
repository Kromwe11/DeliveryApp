//
//  AddDishViewController.swift
//  TestMVP
//
//  Created by Висент Щепетков on 26.01.2024.
//

import UIKit

final class AddDishViewController: UIViewController {
    
    // MARK: Public properties
    var presenter: AddDishPresenterProtocol!
    var imageService: ImageServiceProtocol?
    
    // MARK: - Private properties
    private let contentView = UIView()
    private let imageContainerView = UIView()
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let weightLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let addToCartButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    private let heartButton = UIButton(type: .system)
    
    private enum Constants {
        static let rub = "Р"
        static let gram = "г"
        static let xmarkImage = "xmark"
        static let heartImage = "heart"
        static let addToCart = "Добавить в корзину"
        static let identifierCloseButton = "CloseButton"
        static let identifierAddToCartButton = "AddToCartButton"
        static let imageViewSpacing: CGFloat = 10
        static let contentViewSpacing: CGFloat = 25
        static let imageContainerHeight: CGFloat = 232
        static let imageContainerSpacing: CGFloat = 16
        static let nameLabelSpacing: CGFloat = 8
        static let priceLabelSpacing: CGFloat = 8
        static let weightLabelLeading: CGFloat = 18
        static let weightLabelSpacing: CGFloat = 8
        static let descriptionLabelSpacing: CGFloat = 8
        static let addToCartButtonSpacing: CGFloat = 16
        static let addToCartButtonWidth: CGFloat = 311
        static let addToCartButtonHeight: CGFloat = 48
        static let widthHeightButton: CGFloat = 36
        static let spacingButton: CGFloat = 8
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5) //
        setupContentView()
        setupImageContainerView()
        setupImageView()
        setupNameLabel()
        setupPriceLabel()
        setupWeightLabel()
        setupDescriptionLabel()
        setupAddToCartButton()
        setupCloseButton()
        setupHeartButton()
        presenter.getDishDetails()
    }
    
    // MARK: Private Methods
    private func loadImage(fromURL url: URL, into imageView: UIImageView) {
        imageService?.loadImage(from: url) { image in
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
    }
    
    private func setupContentView() {
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
    }
    
    private func setupImageContainerView() {
        contentView.addSubview(imageContainerView)
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageContainerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16),
            imageContainerView.heightAnchor.constraint(equalToConstant: 232)
        ])
        imageContainerView.backgroundColor = UIColor.castomeGray
        imageContainerView.layer.cornerRadius = 8
    }
    
    private func setupImageView() {
        imageContainerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: Constants.imageViewSpacing),
            imageView.leadingAnchor.constraint(
                equalTo: imageContainerView.leadingAnchor,
                constant: Constants.imageViewSpacing),
            imageView.trailingAnchor.constraint(
                equalTo: imageContainerView.trailingAnchor,
                constant: -Constants.imageViewSpacing),
            imageView.bottomAnchor.constraint(
                equalTo: imageContainerView.bottomAnchor,
                constant: -Constants.imageViewSpacing),
        ])
    }
    
    private func setupCloseButton() {
        imageContainerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: Constants.xmarkImage), for: .normal)
        closeButton.tintColor = .black
        closeButton.backgroundColor = .white
        closeButton.layer.cornerRadius = 7
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.accessibilityIdentifier = Constants.identifierCloseButton
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: Constants.spacingButton),
            closeButton.trailingAnchor.constraint(
                equalTo: imageContainerView.trailingAnchor,
                constant: -Constants.spacingButton),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.widthHeightButton),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.widthHeightButton),
        ])
    }
    
    private func setupHeartButton() {
        imageContainerView.addSubview(heartButton)
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        heartButton.setImage(UIImage(systemName: Constants.heartImage), for: .normal)
        heartButton.tintColor = .black
        heartButton.backgroundColor = .white
        heartButton.layer.cornerRadius = 7
        NSLayoutConstraint.activate([
            heartButton.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: Constants.spacingButton),
            heartButton.trailingAnchor.constraint(
                equalTo: closeButton.leadingAnchor,
                constant: -Constants.spacingButton
            ),
            heartButton.widthAnchor.constraint(equalToConstant: Constants.widthHeightButton),
            heartButton.heightAnchor.constraint(equalToConstant: Constants.widthHeightButton),
        ])
    }
    
    private func setupAddToCartButton() {
        contentView.addSubview(addToCartButton)
        addToCartButton.accessibilityIdentifier = Constants.identifierAddToCartButton
        addToCartButton.translatesAutoresizingMaskIntoConstraints = false
        addToCartButton.setTitle(Constants.addToCart, for: .normal)
        addToCartButton.backgroundColor = .castomeBlue
        addToCartButton.setTitleColor(.white, for: .normal)
        addToCartButton.layer.cornerRadius = 5
        addToCartButton.addTarget(self, action: #selector(addCartButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            addToCartButton.topAnchor.constraint(
                equalTo: descriptionLabel.bottomAnchor,
                constant: Constants.addToCartButtonSpacing
            ),
            addToCartButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.addToCartButtonSpacing
            ),
            addToCartButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addToCartButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            addToCartButton.heightAnchor.constraint(equalToConstant: Constants.addToCartButtonHeight),
        ])
    }
    
    private func setupDescriptionLabel() {
        contentView.addSubview(descriptionLabel)
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .darkGray
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(
                equalTo: priceLabel.bottomAnchor,
                constant: Constants.descriptionLabelSpacing
            ),
            descriptionLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.descriptionLabelSpacing
            ),
        ])
    }
    
    private func setupWeightLabel() {
        contentView.addSubview(weightLabel)
        weightLabel.textColor = .lightGray
        weightLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weightLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: Constants.weightLabelSpacing),
            weightLabel.leadingAnchor.constraint(
                equalTo: priceLabel.trailingAnchor,
                constant: Constants.weightLabelLeading
            ),
        ])
    }
    
    private func setupPriceLabel() {
        contentView.addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.priceLabelSpacing),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
        ])
    }
    
    private func setupNameLabel() {
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .black
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(
                equalTo: imageContainerView.bottomAnchor,
                constant: Constants.nameLabelSpacing
            ),
            nameLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.nameLabelSpacing
            ),
        ])
    }
    
    // MARK: Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func addCartButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: AddDishViewProtocol
extension AddDishViewController: AddDishViewProtocol {
    func displayDishDetails(_ dish: Dish) {
        nameLabel.text = dish.name
        priceLabel.text = "\(dish.price) Р"
        weightLabel.text = "\(dish.weight) г"
        descriptionLabel.text = dish.dishDescription

        guard let url = URL(string: dish.imageURL) else { return }
        loadImage(fromURL: url, into: imageView)
    }
}