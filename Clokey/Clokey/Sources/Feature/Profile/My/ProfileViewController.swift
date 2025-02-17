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
        
//        if let userId = ProfileViewModel.shared.userId {
//            profileView.usernameLabel.text = "@\(userId)"
//            print("ProfileViewController에서 적용된 아이디: \(userId)")
//        }

        loadData()
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
    
    private func loadData() {
//        guard let clokeyId = ProfileViewModel.shared.userId else {
//            print("🚨 사용자 ID 없음")
//            return
//        }
        
        let clokeyId = "qw12"
        
        let membersService = MembersService()
        
        membersService.getUserProfile(clokeyId: clokeyId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userProfile):
                DispatchQueue.main.async {
                    self.profileView.usernameLabel.text = userProfile.clokeyId
                    self.profileView.nicknameLabel.text = userProfile.nickname
                    self.profileView.writeCountLabel.text = "\(userProfile.recordCount)"
                    self.profileView.followerCountButton.setTitle("\(userProfile.followerCount)", for: .normal)
                    self.profileView.followingCountButton.setTitle("\(userProfile.followingCount)", for: .normal)
                    self.profileView.descriptionLabel.text = userProfile.bio
                    
                    if let profileImageUrl = URL(string: userProfile.profileImageUrl) {
                        self.profileView.profileImageView.kf.setImage(with: profileImageUrl)
                    }
                    if let profileBackImageUrl = URL(string: userProfile.profileBackImageUrl) {
                        self.profileView.backgroundImageView.kf.setImage(with: profileBackImageUrl)
                    }
                    
                    if let clothImage1 = userProfile.clothImage1, let clothImageUrl1 = URL(string: clothImage1) {
                        self.profileView.clothesImageView1.kf.setImage(with: clothImageUrl1)
                    } else {
                        self.profileView.clothesImageView1.image = UIImage(named: "default_cloth_image") // 기본 이미지 설정
                    }
                    
                    if let clothImage2 = userProfile.clothImage2, let clothImageUrl2 = URL(string: clothImage2) {
                        self.profileView.clothesImageView2.kf.setImage(with: clothImageUrl2)
                    } else {
                        self.profileView.clothesImageView2.image = UIImage(named: "default_cloth_image")
                    }
                    
                    if let clothImage3 = userProfile.clothImage3, let clothImageUrl3 = URL(string: clothImage3) {
                        self.profileView.clothesImageView3.kf.setImage(with: clothImageUrl3)
                    } else {
                        self.profileView.clothesImageView3.image = UIImage(named: "default_cloth_image")
                    }
                }
            case .failure(let error):
                print("🚨 프로필 데이터를 불러오는 데 실패함: \(error.localizedDescription)")
            }
        }
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
        
//        navigationController?.pushViewController(editProfileViewController, animated: true)
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
