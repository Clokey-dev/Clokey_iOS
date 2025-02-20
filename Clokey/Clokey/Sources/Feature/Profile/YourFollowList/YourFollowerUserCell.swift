//
//  LikeUserCell.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import Foundation
import UIKit
import SnapKit
import Then
import Kingfisher

// MARK: - Like User Cell
class YourFollowerUserCell: UICollectionViewCell {
    static let identifier = "YourFollowerUserCell"
    
    private var isFollowing: Bool = false
    
    // MARK: - UI Components
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .systemGray5
    }
    
    private let userInfoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
    }
    
    private let userIdLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    
    private let nicknameLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 12)
        $0.textColor = .gray
    }
    
    let followButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "팔로우"
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .black
        configuration.cornerStyle = .medium
        
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActions()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(userInfoStackView)
        contentView.addSubview(followButton)
        
        userInfoStackView.addArrangedSubview(userIdLabel)
        userInfoStackView.addArrangedSubview(nicknameLabel)
        
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        userInfoStackView.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(followButton.snp.leading).offset(-12)
        }
        
        followButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(70)
            $0.height.equalTo(30)
        }
    }
    
    private func setupActions() {
        followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    }
    
    // 팔로우 버튼
    @objc private func followButtonTapped() {
        guard let clokeyId = userIdLabel.text else { return }

        followUser(clokeyId: clokeyId)
    }
    
    // 팔로우/언팔로우
    private func followUser(clokeyId: String) {
        let membersService = MembersService()
        
        let wasFollowing = isFollowing
        
        membersService.followUser(clokeyId: clokeyId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.isFollowing.toggle()
                DispatchQueue.main.async {
                    self.updateFollowButton(isFollower: self.isFollowing)
                }
                // 팔로우 걸때만
                if !wasFollowing && self.isFollowing {
                    self.sendFollowNotification(clokeyId: clokeyId)
                }
            case .failure(let error):
                print("팔로우 실패: \(error.localizedDescription)")
            }
        }
    }
    // 팔로우 걸 때 알림
    private func sendFollowNotification(clokeyId: String) {
        let notificationService = NotificationService()
        
        notificationService.notificationFollow(clokeyId: clokeyId) { result in
            switch result {
            case .success:
                print("팔로우 알림 성공")
            case .failure(let error):
                print("팔로우 알림 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Configure
    func configure(with user: YourFollowerUserModel) {
        userIdLabel.text = user.userId
        nicknameLabel.text = user.nickname
        
        if let url = URL(string: user.profileImageUrl) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "profile_basic"))
        }
        
        isFollowing = user.isFollowing
        updateFollowButton(isFollower: user.isFollowing)
        
        if user.isMe {
            followButton.isHidden = true
        } else {
            followButton.isHidden = false
        }
    }
    
    func updateFollowButton(isFollower: Bool) {
        var configuration = UIButton.Configuration.plain()
        configuration.title = isFollower ? "팔로잉" : "팔로우"
        configuration.baseForegroundColor = isFollower ? .black : .white
        configuration.background.backgroundColor = isFollower ? .white : .mainBrown800
        configuration.cornerStyle = .medium
        
        if isFollower {
            followButton.layer.borderWidth = 1
            followButton.layer.masksToBounds = true
            followButton.layer.cornerRadius = 10
            followButton.layer.borderColor = UIColor.mainBrown800.cgColor
        } else {
            followButton.layer.borderWidth = 0
            followButton.layer.cornerRadius = 10
            followButton.layer.masksToBounds = true
        }
        
        followButton.configuration = configuration
    }
}
