//
//  SearchViewController.swift
//  DeliveryApp 
//

import UIKit

final class SearchViewController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundColor()
    }

    // MARK: - Private Methods
    private func setupBackgroundColor() {
        view.backgroundColor = .brown
    }
}
