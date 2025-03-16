//
//  CommentHistoryView.swift
//  Clokey
//
//  Created by 황상환 on 3/16/25.
//

import Foundation
import UIKit
import SnapKit
import Then

final class CommentHistoryView: UIView {
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .white
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    // 댓글 목록을 표시할 테이블 뷰
    let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 80
        $0.register(CommentHistoryCell.self, forCellReuseIdentifier: "CommentHistoryCell")
        $0.tableFooterView = UIView()
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(tableView)
    }
    
    private func setupConstraints() {
        // 스크롤 뷰
        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
            $0.width.equalTo(scrollView)
        }
        
        // 테이블 뷰 크기 지정
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(UIScreen.main.bounds.height - 100)
        }
    }
}

// 댓글 셀 구현
class CommentHistoryCell: UITableViewCell {
    
    // 프로필 이미지
    let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .lightGray
        $0.image = UIImage(systemName: "person.circle.fill")
    }
    
    // 사용자 이름
    let nameLabel = UILabel().then {
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 14)
        $0.textColor = .black
    }
    
    // 날짜
    let dateLabel = UILabel().then {
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .gray
        $0.textAlignment = .right
    }
    
    // 댓글 내용
    let commentBubble = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
    }
    
    let commentLabel = UILabel().then {
        $0.font = UIFont.ptdRegularFont(ofSize: 14)
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .white
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(commentBubble)
        commentBubble.addSubview(commentLabel)
    }
    
    private func setupConstraints() {
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(70)
        }
        
        commentBubble.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nameLabel)
            $0.trailing.lessThanOrEqualToSuperview().offset(-80)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        commentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }
    }
    
    func configure(with comment: CommentModel) {
        nameLabel.text = comment.userName
        dateLabel.text = comment.date
        commentLabel.text = comment.content
        
        // 프로필 이미지 설정
        if let imageUrl = comment.profileImageUrl, let url = URL(string: imageUrl) {
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 셀 재사용 전 초기화
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        nameLabel.text = nil
        dateLabel.text = nil
        commentLabel.text = nil
    }
}

// 댓글 모델
struct CommentModel {
    let id: String
    let userName: String
    let date: String
    let content: String
    let profileImageUrl: String?
}
