//
//  FollowProfileViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/29/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

class FollowProfileViewController: UIViewController {

    // MARK: - Properties
    private let followProfileView = FollowProfileView()
    
    private let model = ProfileModel.dummy()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = followProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followProfileView.scrollView.contentInsetAdjustmentBehavior = .never

        bindData()
    }
    
    private func bindData() {
        // 데이터를 PickView에 바인딩
        followProfileView.clothesImageView1.kf.setImage(with: URL(string: model.profileImageURLs[0]))
        followProfileView.clothesImageView2.kf.setImage(with: URL(string: model.profileImageURLs[1]))
        followProfileView.clothesImageView3.kf.setImage(with: URL(string: model.profileImageURLs[2]))
    }

}
