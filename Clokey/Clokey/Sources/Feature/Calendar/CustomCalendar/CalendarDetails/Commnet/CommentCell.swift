//
//  CommentCell.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import Foundation
import UIKit
import SnapKit
import Then
import Kingfisher

protocol CommentCellDelegate: AnyObject {
    func didTapReplyButton(commentId: Int)
}

class CommentCell: UITableViewCell {
    static let identifier = "CommentCell"
    
    weak var delegate: CommentCellDelegate? // 델리게이트 선언

    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.backgroundColor = .lightGray
    }

    private let nameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textColor = .black
    }

    private let commentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .black
        $0.numberOfLines = 0
    }

    private let replyButton = UIButton().then {
        $0.setTitle("답글 달기", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 12)
        $0.addTarget(self, action: #selector(didTapReply), for: .touchUpInside)
    }

    let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
    }

    let mainStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .top
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(profileImageView)
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(commentLabel)
        contentStackView.addArrangedSubview(replyButton)
        mainStackView.addArrangedSubview(contentStackView)

        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }

        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
    }

    func configure(profileImage: String, name: String, comment: String, isLastReply: Bool, commentId: Int) {
        profileImageView.image = UIImage(named: profileImage)
        nameLabel.text = name
        commentLabel.text = comment
        replyButton.isHidden = !isLastReply
        self.tag = commentId // 해당 셀의 댓글 ID 저장
    }

    @objc private func didTapReply() {
        delegate?.didTapReplyButton(commentId: self.tag) // 델리게이트 호출
    }
}
