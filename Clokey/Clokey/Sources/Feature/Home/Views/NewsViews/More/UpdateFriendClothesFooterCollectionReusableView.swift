//
//  UpdateFriendClothesFooterCollectionReusableView.swift
//  Clokey
//
//  Created by 한금준 on 1/18/25.
//

// 완료

import UIKit
import Then
import SnapKit

class UpdateFriendClothesFooterCollectionReusableView: UICollectionReusableView {
    static let identifier = "UpdateFriendClothesFooterCollectionReusableView"
    
    private let lineView = UIView().then {
        $0.backgroundColor = .systemGray5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20) // 여백 설정
            make.height.equalTo(1) // 높이 1포인트
            make.top.equalToSuperview()
        }
    }
}
