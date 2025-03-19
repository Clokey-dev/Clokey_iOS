//
//  BlockUserCell.swift
//  Clokey
//
//  Created by 한태빈 on 3/19/25.
//

import Foundation
import UIKit
import SnapKit
import Then
import Kingfisher

// MARK: - Like User Cell
class BlockUserCell: UICollectionViewCell {
    static let identifier = "BlockUserCell"
    
    private var isBlocked: Bool = true //true가 차단된 상태, false는 차단 헤제된 상태
    
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
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .gray
    }
    
    let blockButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "차단헤제"//이게 차단된 상태
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .mainBrown800
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
        contentView.addSubview(blockButton)
        
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
            $0.trailing.lessThanOrEqualTo(blockButton.snp.leading).offset(-12)
        }
        
        blockButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(70)
            $0.height.equalTo(30)
        }
    }
    
    // MARK: - Follow/UnFollow
    private func setupActions() {
        blockButton.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
    }
    
    // 팔로우 버튼
    @objc private func blockButtonTapped() {
        guard let clokeyId = userIdLabel.text else { return }

        blockUser(clokeyId: clokeyId)
    }
    
    // 팔로우/언팔로우
    private func blockUser(clokeyId: String) {
        let membersService = MembersService()
        
        let wasblocked = isBlocked
        
        membersService.blockedUser(clokeyId: clokeyId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.isBlocked.toggle()
                DispatchQueue.main.async {
                    self.updateFollowButton(isFollower: self.isBlocked)
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

    // MARK: - Configure
    // configure 함수는 그대로 두고, 버튼 업데이트 부분만 수정
    func configure(with user: BlockUserModel) {
        userIdLabel.text = user.userId
        nicknameLabel.text = user.nickname
        
        if let url = URL(string: user.profileImageUrl) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "profile_basic"))
        }
        
        // 기존의 isFollowing 값을 차단 상태로 활용 (configure쪽은 그대로)
        isBlocked = user.isBlocked
        updateBlockButton(isBlocked: isBlocked)
    }
    
    func updateBlockButton(isBlocked: Bool) {
        var configuration = UIButton.Configuration.plain()
        configuration.cornerStyle = .medium
        
        if isBlocked {
            // 차단된 상태이면 버튼은 "차단헤제" (차단 해제 가능)
            configuration.title = "차단헤제"
            configuration.baseForegroundColor = .white
            configuration.background.backgroundColor = .mainBrown800
        } else {
            // 차단 해제 상태이면 버튼은 "차단" (차단 가능)
            configuration.title = "차단"
            configuration.baseForegroundColor = .black
            configuration.background.backgroundColor = .white
        }
        
        blockButton.configuration = configuration
    }
}
