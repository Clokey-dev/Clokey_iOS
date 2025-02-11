//
//  EmptyStackView.swift
//  Clokey
//
//  Created by 한금준 on 2/8/25.
//

import UIKit

class EmptyStackView: UIView {

    
    /// 빈 상태 아이콘
    let emptyIcon: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(systemName: "exclamationmark.circle")
        $0.tintColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0)
    }
    
    /// 빈 상태 메시지 제목
    let emptyClothesMessageTitle: UILabel = UILabel().then {
        $0.text = "아직 추가한 옷이 없어요!"
        $0.textColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0)
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    /// 빈 상태 메시지 부제목
    let emptyClothesMessageSubTitle: UILabel = UILabel().then {
        $0.text = "내 옷장에 옷을 추가해서\n기온에 맞는 옷을 매일 추천받아 보세요."
        $0.textColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0)
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        addSubview(emptyIcon)
        addSubview(emptyClothesMessageTitle)
        addSubview(emptyClothesMessageSubTitle)
    }
    
    private func setupConstraints() {
        emptyIcon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(55)
        }
        
        emptyClothesMessageTitle.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon.snp.bottom).offset(20)
            make.centerX.equalTo(emptyIcon)
        }
        
        emptyClothesMessageSubTitle.snp.makeConstraints { make in
            make.top.equalTo(emptyClothesMessageTitle.snp.bottom).offset(13)
            make.centerX.equalTo(emptyClothesMessageTitle)
        }
    }
}
