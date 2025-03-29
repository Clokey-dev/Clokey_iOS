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

protocol LikeUserCellDelegate: AnyObject {
    func didTapProfileImage(with clokeyId: String)
    func didRequestAlert(title: String, message: String)
}

// MARK: - Like User Cell
class LikeUserCell: UICollectionViewCell {
    static let identifier = "LikeUserCell"
    
    // MARK: - Properties
    private var userId: String?
    private var followStatus: Bool = false
    weak var delegate: LikeUserCellDelegate?
    
    // MARK: - UI Components
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.isUserInteractionEnabled = true
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
    
    let followButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "팔로우"
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .mainBrown800
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = 10
        
        let attributedTitle = NSAttributedString(
            string: "팔로우",
            attributes: [
                .font: UIFont.ptdRegularFont(ofSize: 16)
            ]
        )
        configuration.attributedTitle = AttributedString(attributedTitle)
        
        let button = UIButton(configuration: configuration)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.mainBrown800.cgColor
        button.layer.cornerRadius = 10
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
            $0.width.equalTo(76)
            $0.height.equalTo(30)
        }
        
        let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
           contentView.addGestureRecognizer(cellTapGesture)
           
        // 팔로우 버튼이 탭 제스처를 가로채도록 설정
        followButton.isUserInteractionEnabled = true
        let folloewButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(followButtonTapped))
        followButton.addGestureRecognizer(folloewButtonTapGesture)
        
    }
    
    // MARK: - ProfileView 이동
    
    @objc private func cellTapped() {
        // userIdLabel의 텍스트(클로키 아이디)를 델리게이트를 통해 전달
        if let clokeyId = userIdLabel.text {
            delegate?.didTapProfileImage(with: clokeyId)
        }
        print("프로필을 클릭 했습니다.")
    }
    
    // MARK: - Configure
    func configure(with user: LikeUserModel) {
        userId = user.userId
        userIdLabel.text = user.userId
        nicknameLabel.text = user.nickname
        followStatus = user.isFollowing
        
        if let url = URL(string: user.profileImageUrl) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "profile_test"))
        }
        
        updateFollowButton(isFollowing: user.isFollowing)
        
        // 본인이면 followButton 숨김
        followButton.isHidden = user.isMe
    }
    
    func updateFollowButton(isFollowing: Bool) {
        followStatus = isFollowing
        var configuration = UIButton.Configuration.plain()
        configuration.title = isFollowing ? "팔로잉" : "팔로우"
        configuration.baseForegroundColor = isFollowing ? .black : .white
        configuration.background.backgroundColor = isFollowing ? .white : .mainBrown800
        
        followButton.configuration = configuration
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.mainBrown800.cgColor    }
    
    // MARK: - 팔로우 기능
    // 팔로우 버튼
    @objc private func followButtonTapped() {
        guard let clokeyId = userIdLabel.text else { return }

        followUser(clokeyId: clokeyId)
    }
    
    // 팔로우/언팔로우
    private func followUser(clokeyId: String) {
        let membersService = MembersService()
        let wasFollowing = followStatus
        
        membersService.followUser(clokeyId: clokeyId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.followStatus.toggle()
                DispatchQueue.main.async {
                    self.updateFollowButton(isFollowing: self.followStatus)
                }
                // 팔로우 걸때만
                if !wasFollowing && self.followStatus {
                    self.sendFollowNotification(clokeyId: clokeyId)
                }
            case .failure(let error):
                print("팔로우 실패: \(error.localizedDescription)")
                delegate?.didRequestAlert(
                    title: "팔로우 실패",
                    message: "네트워크 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요."
                )
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
}
