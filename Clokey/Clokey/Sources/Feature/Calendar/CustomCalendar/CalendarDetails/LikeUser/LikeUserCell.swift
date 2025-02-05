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
class LikeUserCell: UICollectionViewCell {
    static let identifier = "LikeUserCell"
    
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
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .black
    }
    
    private let nicknameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
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
    
    // MARK: - Configure
    func configure(with user: LikeUserModel) {
        userIdLabel.text = user.userId
        nicknameLabel.text = user.nickname
        
        if let url = URL(string: user.profileImageUrl) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "profile_placeholder"))
        }
        
        updateFollowButton(isFollowing: user.isFollowing)
    }
    
    func updateFollowButton(isFollowing: Bool) {
        var configuration = UIButton.Configuration.plain()
        configuration.title = isFollowing ? "팔로잉" : "팔로우"
        configuration.baseForegroundColor = isFollowing ? .black : .white
        configuration.background.backgroundColor = isFollowing ? .white : .black
        configuration.cornerStyle = .medium
        
        if isFollowing {
            followButton.layer.borderWidth = 1
            followButton.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            followButton.layer.borderWidth = 0
        }
        
        followButton.configuration = configuration
    }
}
