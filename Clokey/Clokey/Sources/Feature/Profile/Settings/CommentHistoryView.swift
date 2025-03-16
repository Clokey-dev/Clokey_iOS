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
import Kingfisher

final class CommentHistoryView: UIView {
    
    // 댓글 목록을 표시할 테이블 뷰
    let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 120
        $0.register(CommentHistoryCell.self, forCellReuseIdentifier: "CommentHistoryCell")
        $0.tableFooterView = UIView()
        // 테이블뷰 상하 여백 추가
        $0.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    // 로딩 인디케이터
    let activityIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
        $0.color = .gray
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
        
        addSubview(tableView)
        addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        // 테이블 뷰 직접 배치
        tableView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        // 로딩 인디케이터
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // 로딩 상태 설정
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

// 댓글 셀 구현
class CommentHistoryCell: UITableViewCell {
    
    // 기록 대표 이미지
    let historyImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .lightGray
    }
    
    // 닉네임 추가
    let nickNameLabel = UILabel().then {
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 14)
        $0.textColor = .black
    }
    
    // 날짜
    let dateLabel = UILabel().then {
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .gray
        $0.textAlignment = .right
    }
    
    // 댓글 컨테이너 스택뷰
    let commentsStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.distribution = .fillProportionally
    }
    
    // 댓글 행 생성 함수는 동일
    private func createCommentRow(comment: CommentModel) -> UIView {
        let rowContainer = UIView()
        
        let commentIcon = UIImageView().then {
            $0.image = UIImage(named: "message_icon")
            $0.tintColor = .gray
            $0.contentMode = .scaleAspectFit
        }
        
        let commentLabel = UILabel().then {
            $0.font = UIFont.ptdRegularFont(ofSize: 14)
            $0.textColor = .black
            $0.numberOfLines = 0
            $0.text = comment.content
        }
        
        rowContainer.addSubview(commentIcon)
        rowContainer.addSubview(commentLabel)
        
        commentIcon.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.size.equalTo(CGSize(width: 22, height: 22))
        }
        
        commentLabel.snp.makeConstraints {
            $0.leading.equalTo(commentIcon.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        return rowContainer
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
        contentView.addSubview(historyImageView)
        contentView.addSubview(nickNameLabel) // 닉네임 추가
        contentView.addSubview(dateLabel)
        contentView.addSubview(commentsStackView)
    }
    
    private func setupConstraints() {
        historyImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(CGSize(width: 40, height: 40)) // 이미지 크기 조정
        }
        
        // 닉네임 위치 설정
        nickNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.leading.equalTo(historyImageView.snp.trailing).offset(12)
        }
        
        // 날짜를 오른쪽으로 위치시킴
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(nickNameLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.leading.greaterThanOrEqualTo(nickNameLabel.snp.trailing).offset(8) // 닉네임과 겹치지 않도록
        }
        
        // 댓글 스택뷰 위치 조정
        commentsStackView.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(15) // 닉네임 아래
            $0.leading.equalTo(historyImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-16).priority(.high)
        }
    }
    
    func configure(with history: HistoryModel) {
        // 닉네임 설정
        nickNameLabel.text = "\(history.nickname)님의 기록"
        
        // 날짜 형식 변환 (YYYY-MM-DD → YYYY.MM.DD)
        let dateComponents = history.date.split(separator: "-").map { String($0) }
        if dateComponents.count == 3 {
            dateLabel.text = dateComponents.joined(separator: ".")
        } else {
            dateLabel.text = history.date
        }
        
        // 이미지 설정 - Kingfisher 사용
        if let url = URL(string: history.imageUrl) {
            historyImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder_image"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ],
                completionHandler: { result in
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        print("이미지 로딩 실패: \(error.localizedDescription)")
                    }
                }
            )
        } else {
            historyImageView.image = UIImage(named: "placeholder_image")
        }
        
        // 기존 댓글 뷰 제거
        commentsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 댓글 추가
        for comment in history.comments {
            let commentView = createCommentRow(comment: comment)
            commentsStackView.addArrangedSubview(commentView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 셀 재사용 전 초기화
        historyImageView.kf.cancelDownloadTask()
        historyImageView.image = nil
        nickNameLabel.text = nil
        dateLabel.text = nil
        commentsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
