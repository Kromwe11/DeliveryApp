//
//  UserViewController.swift
//  TestMVP
//
//  Created by Висент Щепетков on 02.02.2024.
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
