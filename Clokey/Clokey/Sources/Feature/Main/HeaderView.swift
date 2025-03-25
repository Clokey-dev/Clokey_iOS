//
//  HeaderView.swift
//  Clokey
//
//  Created by 황상환 on 1/20/25.
//

import Foundation
import UIKit
import SnapKit
import Then

// HeaderView 이벤트 처리 델리게이트 프로토콜
protocol HeaderViewDelegate: AnyObject {
    // 검색 버튼
    func didTapSearchButton()
    // 알림 버튼
    func didTapNotificationButton()
    
    
    

}

final class HeaderView: UIView {
    
    // MARK: - Properties
    // weak 참조하면 메모리 해제 용이
    // ?: 델리게이트 없어도 뷰 작동 가능
    weak var delegate: HeaderViewDelegate?
    
    // MARK: - UI Components
    // 로고 라벨
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "Clokey"
        label.font = UIFont(name: "NotoSansKR-ExtraBold", size: 20)
        label.textColor = .mainBrown800

        // letterSpacing 적용
        let attributedString = NSMutableAttributedString(string: "Clokey", attributes: [
            .kern: 0.8 // letter-spacing 4% (20 * 0.04 = 0.8)
        ])
        label.attributedText = attributedString

        return label
    }()
    
    // 검색 버튼
    private let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "searchicon"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    // 알림 버튼
    private let notificationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "bell"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
   
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        [logoLabel, searchButton, notificationButton].forEach { addSubview($0) }
    }
    
    private func setupConstraints() {
        // 로고 라벨
        logoLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(20)
            
        }
        
        // 검색 버튼
        searchButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(notificationButton.snp.leading).offset(-16)
            $0.size.equalTo(24)
        }
        
        // 알림 버튼
        notificationButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(-16)
            $0.size.equalTo(24)
        }
        
      /* notificationUnreadButton.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(-16)
            $0.size.equalTo(24)
        }*/
        
    }
    
    // 검색/알림 버튼 이벤트 핸들러
    private func setupActions() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        notificationButton.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    //각 델리게이트를 통해 이벤트를 상위 객체에 전달
    
    @objc private func searchButtonTapped() {
        delegate?.didTapSearchButton()
    }
    
    @objc private func notificationButtonTapped() {
        delegate?.didTapNotificationButton()
    }
    
    
    func updateNotificationIcon(isUnread: Bool) {
            print("updateNotificationIcon 호출됨, isUnread: \(isUnread)")
            let imageName = isUnread ? "bellUnread" : "bell"
            if let image = UIImage(named: imageName) {
                notificationButton.setImage(image, for: .normal)
            } else {
                print("이미지 \(imageName)이(가) 존재하지 않습니다.")
            }
            // 버튼 내 이미지 뷰가 이미지 크기를 맞추도록 설정
            notificationButton.imageView?.contentMode = .scaleAspectFit
        }
        
}
