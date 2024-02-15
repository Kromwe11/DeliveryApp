//
//  CategoryButtonCell.swift
//  TestMVP
//
//  Created by Висент Щепетков on 26.01.2024.
//

import UIKit

final class DishCategoryButtonCell: UICollectionViewCell {
    // MARK: - Private properties
    private let nameLabel = UILabel()
    
    // MARK: - override properties
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .castomeBlue : UIColor.castomeGray
            nameLabel.textColor = isSelected ? .white : .black
        }
    }
    
    // MARK: Public Methods
    func configure(with categoryName: String) {
        setupCell()
        setupNameLabel()
        nameLabel.text = categoryName
        contentView.backgroundColor = isSelected ? .castomeBlue : UIColor.castomeGray
        nameLabel.textColor = isSelected ? .white : .black
    }
    
    // MARK: Private Methods
    private func setupCell() {
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 15)
    }
}
