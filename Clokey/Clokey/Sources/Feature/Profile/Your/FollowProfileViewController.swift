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
    
    private let calendarViewController = CalendarViewController()
    
    var followId: String = ""
    var clokey_Id: String = ""
    var followerCount: Int = 0
    var followingCount: Int = 0
    
    // MARK: - Lifecycle
    override func loadView() {
        view = followProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followProfileView.scrollView.contentInsetAdjustmentBehavior = .never
        
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
        
//        let clokeyId = followId
        
        let membersService = MembersService()
        
        
        membersService.getUserProfile(clokey_id: followId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userProfile):
                DispatchQueue.main.async {
                    self.followProfileView.usernameLabel.text = userProfile.clokeyId
                    self.clokey_Id = userProfile.clokeyId
                    self.followProfileView.nicknameLabel.text = userProfile.nickname
                    self.followProfileView.writeCountLabel.text = "\(userProfile.recordCount)"
                    self.followProfileView.followerCountButton.setTitle("\(userProfile.followerCount)", for: .normal)
                    self.followerCount = userProfile.followerCount
                    self.followProfileView.followingCountButton.setTitle("\(userProfile.followingCount)", for: .normal)
                    self.followingCount = userProfile.followingCount
                    self.followProfileView.descriptionLabel.text = userProfile.bio
                    
                    
                    if let profileImageUrl = userProfile.profileImageUrl,
                       let url = URL(string: profileImageUrl) {
                        self.followProfileView.profileImageView.kf.setImage(with: url)
                    } else {
                        self.followProfileView.profileImageView.image = UIImage(named: "default_background_image") // 기본 이미지 설정
                    }
                    if let profileBackImageUrl = URL(string: userProfile.profileBackImageUrl) {
                        self.followProfileView.backgroundImageView.kf.setImage(with: profileBackImageUrl)
                    }
                    
                    if let clothImage1 = userProfile.clothImage1, let clothImageUrl1 = URL(string: clothImage1) {
                        self.followProfileView.clothesImageView1.kf.setImage(with: clothImageUrl1)
                    } else {
                        self.followProfileView.clothesImageView1.image = UIImage(named: "default_cloth_image") // 기본 이미지 설정
                    }
                    
                    if let clothImage2 = userProfile.clothImage2, let clothImageUrl2 = URL(string: clothImage2) {
                        self.followProfileView.clothesImageView2.kf.setImage(with: clothImageUrl2)
                    } else {
                        self.followProfileView.clothesImageView2.image = UIImage(named: "default_cloth_image")
                    }
                    
                    if let clothImage3 = userProfile.clothImage3, let clothImageUrl3 = URL(string: clothImage3) {
                        self.followProfileView.clothesImageView3.kf.setImage(with: clothImageUrl3)
                    } else {
                        self.followProfileView.clothesImageView3.image = UIImage(named: "default_cloth_image")
                    }
                    guard let isFollowing = userProfile.isFollowing else {
                        self.followProfileView.followButton.setTitle("팔로우", for: .normal)
                        self.followProfileView.followButton.backgroundColor = .mainBrown800
                        self.followProfileView.followButton.setTitleColor(.white, for: .normal)
                        self.followProfileView.followButton.layer.borderColor = UIColor.mainBrown800.cgColor
                        self.followProfileView.followButton.layer.borderWidth = 1
                        return
                    }
                    
                    if isFollowing {
                        self.followProfileView.followButton.setTitle("팔로잉", for: .normal)
                        self.followProfileView.followButton.backgroundColor = .white
                        self.followProfileView.followButton.setTitleColor(.black, for: .normal)
                        self.followProfileView.followButton.layer.borderColor = UIColor.mainBrown800.cgColor
                        self.followProfileView.followButton.layer.borderWidth = 1
                    } else {
                        self.followProfileView.followButton.setTitle("팔로우", for: .normal)
                        self.followProfileView.followButton.backgroundColor = .mainBrown800
                        self.followProfileView.followButton.setTitleColor(.white, for: .normal)
                        self.followProfileView.followButton.layer.borderColor = UIColor.mainBrown800.cgColor
                        self.followProfileView.followButton.layer.borderWidth = 1
                    }
                }
            case .failure(let error):
                print("🚨 프로필 데이터를 불러오는 데 실패함: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupActions() {
        followProfileView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        followProfileView.followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        followProfileView.followerCountButton.addTarget(self, action: #selector(didTapFollowerButton), for: .touchUpInside)
        followProfileView.followingCountButton.addTarget(self, action: #selector(didTapFollowingButton), for: .touchUpInside)
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapFollowButton() {
        guard let clokeyId = ProfileViewModel.shared.userId else {
            print("🚨 사용자 ID 없음")
            return
        }
        
        //        let clokeyId = "qw12"
        
        let isCurrentlyFollowing = followProfileView.followButton.backgroundColor
        let followService = MembersService()
        let requestDTO = FollowRequestDTO(myClokeyId: clokeyId, yourClokeyId: followId)
        
        // 팔로우 중이면 -> 언팔 API 호출 / 팔로우 중이 아니면 -> 팔로우 API 호출
        followService.followUser(data: requestDTO) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if isCurrentlyFollowing == .mainBrown800 {
                        // 언팔로우 상태로 변경
                        self.followProfileView.followButton.setTitle("팔로우", for: .normal)
                        self.followProfileView.followButton.backgroundColor = .white
                        self.followProfileView.followButton.setTitleColor(.black, for: .normal)
                        self.followProfileView.followButton.layer.borderColor = UIColor.mainBrown800.cgColor
                        self.followProfileView.followButton.layer.borderWidth = 1
                    } else {
                        // 팔로잉 상태로 변경
                        self.followProfileView.followButton.setTitle("팔로잉", for: .normal)
                        self.followProfileView.followButton.backgroundColor = .mainBrown800
                        self.followProfileView.followButton.setTitleColor(.white, for: .normal)
                        self.followProfileView.followButton.layer.borderColor = UIColor.mainBrown800.cgColor
                        self.followProfileView.followButton.layer.borderWidth = 1
                    }
                case .failure(let error):
                    print("🚨 팔로우/언팔로우 요청 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    @objc private func didTapFollowerButton() {
        let followListViewController = YourFollowListViewController()
        followListViewController.selectedTab = .follower // 팔로워 탭으로 설정
        followListViewController.followerCount = followerCount
        followListViewController.followingCount = followingCount
        followListViewController.clokeyId = self.clokey_Id
        navigationController?.pushViewController(followListViewController, animated: true)
    }
    
    @objc private func didTapFollowingButton() {
        let followListViewController = YourFollowListViewController()
        followListViewController.selectedTab = .following // 팔로잉 탭으로 설정
        followListViewController.followerCount = followerCount
        followListViewController.followingCount = followingCount
        followListViewController.clokeyId = self.clokey_Id
        navigationController?.pushViewController(followListViewController, animated: true)
    }
    
}
