//
//  ProfileViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/10/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ProfileViewController: UIViewController {
    private let mainView = MainView()
    // MARK: - Properties
    private let profileView = ProfileView()
    
    private let model = ProfileModel.dummy()
    
    // MARK: - Lifecycle
    override func loadView() {
        
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.scrollView.contentInsetAdjustmentBehavior = .never

        bindData()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 네비게이션 바 숨기기 강제 적용
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        additionalSafeAreaInsets.top = 0
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    
    private func bindData() {
        // 데이터를 PickView에 바인딩
        profileView.clothesImageView1.kf.setImage(with: URL(string: model.profileImageURLs[0]))
        profileView.clothesImageView2.kf.setImage(with: URL(string: model.profileImageURLs[1]))
        profileView.clothesImageView3.kf.setImage(with: URL(string: model.profileImageURLs[2]))
    }
    
    
    private func setupActions() {
        profileView.settingButton.addTarget(self, action: #selector(didTapSettingButton), for: .touchUpInside)
        
        profileView.editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        
        profileView.followerCountButton.addTarget(self, action: #selector(didTapFollowerButton), for: .touchUpInside)
        
        profileView.followingCountButton.addTarget(self, action: #selector(didTapFollowingButton), for: .touchUpInside)
    }

    @objc private func didTapSettingButton() {
        let settingViewController = SettingViewController()
        settingViewController.modalPresentationStyle = .fullScreen // 전체 화면으로 표시
        present(settingViewController, animated: true, completion: nil)
    }
    
    @objc private func didTapEditButton() {
        let editProfileViewController = EditProfileViewController()
        editProfileViewController.modalPresentationStyle = .fullScreen // 전체 화면으로 표시
        present(editProfileViewController, animated: true, completion: nil)
    }
    
    @objc private func didTapFollowerButton() {
        let followListViewController = FollowListViewController()
//        followListViewController.updateCollectionView(for: .follower)
        followListViewController.selectedTab = .follower // 팔로워 탭으로 설정
        followListViewController.modalPresentationStyle = .fullScreen // 전체 화면으로 표시
        present(followListViewController, animated: true, completion: nil)
    }
    
    @objc private func didTapFollowingButton() {
        let followListViewController = FollowListViewController()
        followListViewController.modalPresentationStyle = .fullScreen // 전체 화면으로 표시
//        followListViewController.updateCollectionView(for: .following)
        followListViewController.selectedTab = .following // 팔로잉 탭으로 설정
        present(followListViewController, animated: true, completion: nil)
    }
}
