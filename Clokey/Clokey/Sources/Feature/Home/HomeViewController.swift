//
//  HomeViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/10/25.
//

import Foundation
import Foundation
import UIKit
import SnapKit
import Then

final class HomeViewController: UIViewController {
    // MARK: - Properties
    private let homeView = HomeView()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = homeView
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
