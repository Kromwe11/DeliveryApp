//
//  CategoryTableViewCell.swift
//  TestMVP
//
//  Created by Висент Щепетков on 25.01.2024.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    // MARK: - Public properties
    var imageService: ImageServiceProtocol!
    
    // MARK: - Private properties
    private enum Constants {
        static let imageViewHeight: CGFloat = 148
        static let imageViewWidth: CGFloat = 343
        static let imageViewCornerRadius: CGFloat = 10
        static let titleLabelHeight: CGFloat = 50
        static let titleLabelWidth: CGFloat = 191
        static let titleLabelFontSize: CGFloat = 20
        static let padding: CGFloat = 16
        static let titleLabelTopSpace: CGFloat = 12
        static let titleLabelLeadingSpace: CGFloat = 12
        static let placeholder = "placeholder"
    }
    
    private var currentLoadTask: URLSessionDataTask?
    private let titleLabel = UILabel()
    private let categoryImageView = UIImageView()
    
    // MARK: - Override Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        currentLoadTask?.cancel()
        currentLoadTask = nil
        categoryImageView.image = UIImage(named: Constants.placeholder)
        titleLabel.text = nil
    }
    
    // MARK: - Public Methods
    func configure(with category: CategoryDish) {
        setupCategoryImageView()
        setupTitleLabel()
        titleLabel.text = category.name
        loadImage(for: category)
    }
    
    // MARK: - Private Methods
    private func loadImage(for category: CategoryDish) {
        guard let url = URL(string: category.imageURL) else { return }
        let identifier = imageService.generateFileName(from: url)
        currentLoadTask?.cancel()
        
        currentLoadTask = imageService.loadImage(from: url) { [weak self] image in
            DispatchQueue.main.async {
                if let image = image {
                    self?.categoryImageView.image = image
                    self?.imageService.saveImage(image, withIdentifier: identifier)
                } else {
                    self?.categoryImageView.image = UIImage(named: Constants.placeholder)
                }
            }
        }
        currentLoadTask?.resume()
    }
    
    private func setupCategoryImageView() {
        categoryImageView.layer.cornerRadius = Constants.imageViewCornerRadius
        categoryImageView.clipsToBounds = true
        categoryImageView.contentMode = .scaleAspectFill
        categoryImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryImageView)
        NSLayoutConstraint.activate([
            categoryImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.padding),
            categoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            categoryImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.padding),
            categoryImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.padding),
            categoryImageView.heightAnchor.constraint(equalToConstant: Constants.imageViewHeight)
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: Constants.titleLabelFontSize, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryImageView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: categoryImageView.topAnchor,
                constant: Constants.titleLabelTopSpace),
            titleLabel.leadingAnchor.constraint(
                equalTo: categoryImageView.leadingAnchor,
                constant: Constants.titleLabelLeadingSpace),
            titleLabel.heightAnchor.constraint(equalToConstant: Constants.titleLabelHeight),
            titleLabel.widthAnchor.constraint(equalToConstant: Constants.titleLabelWidth)
        ])
    }
}
