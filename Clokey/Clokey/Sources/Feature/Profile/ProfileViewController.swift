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
    
    private let model = ProfileModel.dummy()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindData()
    }
    
    private func bindData() {
        // 데이터를 PickView에 바인딩
        profileView.clothesImageView1.kf.setImage(with: URL(string: model.profileImageURLs[0]))
        profileView.clothesImageView2.kf.setImage(with: URL(string: model.profileImageURLs[1]))
        profileView.clothesImageView3.kf.setImage(with: URL(string: model.profileImageURLs[2]))
    }
}
