//
//  ProfileViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/10/25.
//

import Foundation
import UIKit
import SnapKit
import Then

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    private let profileView = ProfileView()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .gray
    }
}
