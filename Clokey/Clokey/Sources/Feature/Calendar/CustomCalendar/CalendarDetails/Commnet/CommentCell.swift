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
    func didTapReplyButton(commentId: Int64)
}

class CommentCell: UITableViewCell {
    static let identifier = "CommentCell"
    
    weak var delegate: CommentCellDelegate? // 델리게이트 선언

    private let containerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 17.5
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

    private lazy var replyButton: UIButton = {
        let button = UIButton()
        button.setTitle("답글 달기", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(didTapReply), for: .touchUpInside)
        return button
    }()


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
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(profileImageView)
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(commentLabel)
        contentStackView.addArrangedSubview(replyButton)
        mainStackView.addArrangedSubview(contentStackView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        mainStackView.snp.makeConstraints {
           $0.edges.equalToSuperview()
        }

        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(35)
        }
    }

    func configure(profileImage: String, name: String, comment: String, isLastReply: Bool, commentId: Int) {
        if let url = URL(string: profileImage) {
            profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "profile_test"),
                options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 35, height: 35))),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.2))
                ]
            )
        } else {
            profileImageView.image = UIImage(named: "profile_test")
        }
        
        nameLabel.text = name
        commentLabel.text = comment
        replyButton.isHidden = !isLastReply
        self.tag = Int(commentId)
    }
    
    func setSelected(_ selected: Bool) {
        super.setSelected(selected, animated: false)
        if selected {
            // 먼저 오렌지색으로 변경
            UIView.animate(withDuration: 0.2) {
                self.containerView.backgroundColor = .pointOrange800.withAlphaComponent(0.1)
            } completion: { _ in
                // 0.5초 후에 다시 흰색으로 페이드아웃
                UIView.animate(withDuration: 0.5, delay: 0.5) {
                    self.containerView.backgroundColor = .white
                }
            }
        } else {
            self.containerView.backgroundColor = .white
        }
    }
    

    @objc private func didTapReply() {
        delegate?.didTapReplyButton(commentId: Int64(self.tag)) 
    }
}
