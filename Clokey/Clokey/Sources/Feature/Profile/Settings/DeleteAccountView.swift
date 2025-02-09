//
//  DeleteAccountView.swift
//  Clokey
//
//  Created by 한금준 on 2/4/25.
//

import UIKit

class DeleteAccountView: UIView {
    
    let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .black
    }
    
    let deleteAccountLabel = UILabel().then {
        $0.text = "계정 탈퇴"
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    let warningIcon = UIImageView().then {
        $0.image = UIImage(systemName: "exclamationmark.octagon")
        $0.tintColor = UIColor(red: 246/255, green: 104/255, blue: 46/255, alpha: 0.5)
    }
    
    let warningLabel = UILabel().then {
        $0.text = "잠깐! 계정 탈퇴 전\n아래 내용을 확인해주세요."
        $0.textColor = .pointOrange600
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    // 안내 카드 1
    lazy var firstCard = createInfoCard(icon: UIImage(named: "cry_icon"), title: "처음부터 다시 가입해야 해요.",
                                        description: "탈퇴 회원의 정보는 15일 간 임시 보관되고\n그 이후 완전히 삭제돼요.\n탈퇴하시면 회원가입부터 다시 해야 해요.")
    
    lazy var secondCard = createInfoCard(icon: UIImage(named: "cry_icon"), title: "옷을 전부 다시 등록해야 해요.",
                                         description: "탈퇴 후에는 등록된 옷과 캘린더 기록이\n전부 삭제돼요. 옷을 전부 다시 등록하고\n기록을 처음부터 다시 해야 해요.")
    
    // 하단 버튼 스택
    let buttonStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 11
        $0.distribution = .fillEqually
    }
    
    let cancelButton = UIButton(type: .system).then {
        $0.setTitle("취소하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .orange
        $0.layer.cornerRadius = 10
    }
    
    let deleteButton = UIButton(type: .system).then {
        $0.setTitle("계정 탈퇴", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        $0.layer.cornerRadius = 10    }
    
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
        
        addSubviews(backButton, deleteAccountLabel, warningIcon, warningLabel, firstCard, secondCard, buttonStack)
        
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(deleteButton)
    }
    
    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(11)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 10, height: 20))
        }
        
        deleteAccountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(20)
        }
        
        warningIcon.snp.makeConstraints { make in
            make.top.equalTo(deleteAccountLabel.snp.bottom).offset(63)
            make.centerX.equalToSuperview()
            make.width.equalTo(85)
            make.height.equalTo(79)
        }
        
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(warningIcon.snp.bottom).offset(8)
            make.centerX.equalTo(warningIcon)
        }
        
        firstCard.snp.makeConstraints { make in
            make.top.equalTo(warningLabel.snp.bottom).offset(31)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        secondCard.snp.makeConstraints { make in
            make.top.equalTo(firstCard.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        
        
    }
    
    private func createInfoCard(icon: UIImage?, title: String, description: String) -> UIView {
        let cardView = UIView().then {
            $0.backgroundColor = UIColor(red: 255/255, green: 248/255, blue: 235/255, alpha: 1)
            $0.layer.cornerRadius = 10
        }
        
        let iconLabel = UIImageView().then {
                $0.image = icon
                $0.contentMode = .scaleAspectFit
            }
        
        cardView.addSubview(iconLabel)
        iconLabel.snp.makeConstraints { make in
//            make.leading.top.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(17)
            make.width.height.equalTo(56)
        }
        
        let titleLabel = UILabel().then {
            $0.text = title
            $0.font = UIFont.boldSystemFont(ofSize: 16)
            $0.textColor = .black
        }
        cardView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(16)
        }
        
        let descriptionLabel = UILabel().then {
            $0.text = description
            $0.font = UIFont.systemFont(ofSize: 14)
            $0.textColor = .darkGray
            $0.numberOfLines = 0
        }
        cardView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel.snp.trailing).offset(8)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.bottom.equalToSuperview().inset(16)
        }
        
        return cardView
    }
    
}
