//
//  CustomSearchField.swift
//  Clokey
//
//  Created by 황상환 on 1/31/25.
//

import UIKit
import SnapKit

class CustomSearchField: UIView {
    
    // 검색 아이콘
    private let searchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "search_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 텍스트 필드
    let textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.borderStyle = .none
        textField.font = UIFont.ptdMediumFont(ofSize: 16)
        textField.textColor = UIColor.black

        // placeholder 스타일 설정
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.ptdMediumFont(ofSize: 16)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "내 옷 검색하기", attributes: placeholderAttributes)

        return textField
    }()

    // 컨테이너 뷰
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10  // 둥근 모서리
        view.layer.borderWidth = 1    // 테두리 두께
        view.layer.borderColor = UIColor.pointOrange800.cgColor
        return view
    }()
    
    // 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 컨테이너 뷰 추가
        addSubview(containerView)
        containerView.addSubview(searchImageView)
        containerView.addSubview(textField)
        
        // 레이아웃 설정
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        searchImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(19)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        
        textField.snp.makeConstraints {
            $0.leading.equalTo(searchImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func setPlaceholder(_ placeholder: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.ptdMediumFont(ofSize: 16)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }
}
