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
    private let viewModel: HomeViewModel
    private let homeView = HomeView()
    
    // MARK: - Init
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
