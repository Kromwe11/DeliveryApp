//
//  UserViewController.swift
//  DeliveryApp 
//

import UIKit

final class UserViewController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundColor()
    }

    // MARK: - Private Methods
    private func setupBackgroundColor() {
        view.backgroundColor = .blue
    }
}
