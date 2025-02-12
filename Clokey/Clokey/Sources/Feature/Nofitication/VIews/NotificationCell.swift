//
//  NotificationCell.swift
//  Clokey
//
//  Created by 소민준 on 2/11/25.
//


//
//  NotificationCell.swift
//  Alarm
//
//  Created by 소민준 on 2/8/25.
//



import UIKit
import SnapKit
import Kingfisher // 서버에서 이미지 로드할 때 사용

class NotificationCell: UITableViewCell {
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 18 // 36x36이므로 반으로 둥글게
        imageView.backgroundColor = .lightGray // 기본 배경 (서버 이미지 로딩 전)
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(messageLabel)

        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(36) // 36x36 사이즈 적용
        }

        messageLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(36) // 라벨 높이 36
            $0.centerY.equalToSuperview()
        }
    }

    func configure(with notification: NotificationItem) {
        messageLabel.text = notification.title
        
        if let imageUrl = notification.imageUrl, let url = URL(string: imageUrl) {
            profileImageView.kf.setImage(with: url) // Kingfisher로 이미지 로드
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill") // 기본 이미지
        }

        backgroundColor = notification.isRead ? .white : UIColor(white: 1, alpha: 1) // 읽지 않은 경우 회색 배경
    }
}
