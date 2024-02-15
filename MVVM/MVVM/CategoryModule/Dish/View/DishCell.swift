//
//  DishCell.swift
//  TestMVP
//
//  Created by Висент Щепетков on 26.01.2024.
//

import UIKit

final class DishCell: UICollectionViewCell {
    
    // MARK: - Public properties
    var imageService: ImageServiceProtocol!
    
    // MARK: - Private properties
    private let grayView = UIView()
    private let dishImageView = UIImageView()
    private let nameLabel = UILabel()
    private var currentLoadTask: URLSessionDataTask?
    private enum Constants {
        static let placeholder = "placeholder"
    }
    
    // MARK: Public Methods
    func configure(with dish: Dish) {
        setupGrayView()
        setupDishImageView()
        setupNameLabel()
        nameLabel.text = dish.name
        loadImage(for: dish)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentLoadTask?.cancel()
        currentLoadTask = nil
        dishImageView.image = UIImage(named: Constants.placeholder)
        nameLabel.text = nil
    }
    
    // MARK: Private Methods
    private func loadImage(for dish: Dish) {
        guard let imageURL = URL(string: dish.imageURL) else {
            dishImageView.image = UIImage(named: Constants.placeholder)
            return
        }
        currentLoadTask?.cancel()
        currentLoadTask = imageService.loadImage(from: imageURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.dishImageView.image = image ?? UIImage(named: Constants.placeholder)
            }
        }
        currentLoadTask?.resume() 
    }
    
    private func setupGrayView() {
        grayView.backgroundColor = .castomeGray
        grayView.layer.cornerRadius = 10
        grayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(grayView)
        
        NSLayoutConstraint.activate([
            grayView.topAnchor.constraint(equalTo: topAnchor),
            grayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            grayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            grayView.heightAnchor.constraint(equalTo: grayView.widthAnchor)
        ])
    }
    
    private func setupDishImageView() {
        dishImageView.contentMode = .scaleAspectFit
        dishImageView.clipsToBounds = true
        dishImageView.translatesAutoresizingMaskIntoConstraints = false
        grayView.addSubview(dishImageView)
        let imagePadding: CGFloat = 10
        NSLayoutConstraint.activate([
            dishImageView.centerXAnchor.constraint(equalTo: grayView.centerXAnchor),
            dishImageView.centerYAnchor.constraint(equalTo: grayView.centerYAnchor),
            dishImageView.heightAnchor.constraint(
                equalTo: grayView.heightAnchor,
                constant: -imagePadding * 2),
            dishImageView.widthAnchor.constraint(equalTo: dishImageView.heightAnchor)
        ])
    }
    
    private func setupNameLabel() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: grayView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
}
