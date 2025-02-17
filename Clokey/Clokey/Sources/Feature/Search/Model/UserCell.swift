//
//  UserCell.swift
//  Clokey
//
//  Created by 소민준 on 2/10/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

// MARK: - User Cell
class UserCell: UICollectionViewCell {
    static let identifier = "UserCell"
    
    // MARK: - UI Components
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .systemGray5
        $0.image = UIImage(named: "profile_placeholder") // 기본 프로필 이미지 추가
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(userInfoStackView)
        
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
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    
    // MARK: - Configure
    func configure(with user: UserModel) {
        userIdLabel.text = user.clokeyId
        nicknameLabel.text = user.nickname
        
        if let url = URL(string: user.profileImage) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "profile_placeholder"))
        }
    }
}
