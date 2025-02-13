//
//  AddClothesView.swift
//  GitTest
//
//  Created by 한금준 on 2/6/25.
//

import UIKit

class AddClothesView: UIView {
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left")?.withTintColor(.mainBrown800, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFit
        
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "옷 추가"
        label.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    /// 🔹 "옷의 이름을 입력해주세요!" 타이틀
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "옷의 이름을 입력해주세요!"
        label.font = UIFont.ptdSemiBoldFont(ofSize: 24)
        label.textAlignment = .left
        label.textColor = .mainBrown800
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "옷 이름을 설정하고 입력 버튼을 누르시면\n카테고리 자동 분류가 이루어집니다."
        label.font = UIFont.ptdMediumFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .mainBrown400
        label.numberOfLines = 2
        return label
    }()
    
    let inputContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    let inputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "옷의 이름을 입력해주세요"
        textField.font = UIFont.ptdMediumFont(ofSize: 16)
        textField.borderStyle = .none  // ✅ 기본 보더 제거
        textField.textColor = .black
        
        return textField
    }()
    
    let inputButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("입력", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // ✅ 버튼 스타일 수정
        btn.backgroundColor = .clear  // ✅ 기본 배경 투명
        btn.layer.borderWidth = 1      // ✅ 테두리 추가
        btn.layer.borderColor = UIColor.mainBrown400.cgColor // ✅ 테두리 색상 설정
        btn.layer.cornerRadius = 10    // ✅ 둥근 모서리 설정
        btn.clipsToBounds = true       // ✅ 클립 적용
        
        return btn
    }()
    
    let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBrown400  // ✅ 검정색 밑줄
        return view
    }()
    
    let categoryContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    /// 🔹 카테고리 태그 정렬 StackView (ex: 상의 > 후드티)
    let categoryTagsContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    /// 🔹 "카테고리 재분류" 안내 텍스트
    let reclassifyLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리 재분류를 원하시나요?"
        label.font = UIFont.ptdMediumFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    let reclassifyButton: UIButton = {
        let btn = UIButton(type: .custom) // ✅ 기본 `.system`이 아닌 `.custom`으로 변경
        let title = NSAttributedString(
            string: "직접 분류하기",
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: UIColor.gray]
        )
        btn.setAttributedTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 14)
        return btn
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.backgroundColor = UIColor(named: "mainBrown400") // ✅ 초기 색상 (비활성화)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = false // ✅ 초기에는 비활성화
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        print("📌 hitTest 호출됨. 터치 위치: \(point)")
        
        // ✅ `reclassifyButton`이 터치된 경우, 무조건 버튼을 반환하도록 수정
        let buttonPoint = convert(point, to: reclassifyButton)
        if reclassifyButton.point(inside: buttonPoint, with: event) {
            print("✅ reclassifyButton이 터치 이벤트를 받음")
            return reclassifyButton
        }
        
        return super.hitTest(point, with: event)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if reclassifyButton.frame.contains(point) {
            print("📌 reclassifyButton 터치 가능")
            return true
        }
        
        let isInside = super.point(inside: point, with: event)
        print("📌 pointInside 결과: \(isInside) - 터치된 위치: \(point)")
        return isInside
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(descriptionLabel)
        
        addSubview(inputContainer)
        inputContainer.addSubview(inputField)
        inputContainer.addSubview(inputButton)
        inputContainer.addSubview(underlineView)  // ✅ 밑줄 추가
        
        addSubview(categoryContainer)
        categoryContainer.addSubview(categoryTagsContainer)
        categoryContainer.addSubview(reclassifyLabel)
        categoryContainer.addSubview(reclassifyButton)
        
        addSubview(nextButton)
        
        
    }
    
    private func setupConstraints() {
        backButton.snp.makeConstraints {
            $0.top.leading.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(29)
            $0.leading.equalToSuperview().offset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }
        
        inputContainer.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(57) // 설명 아래 30pt
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(39)
        }
        
        inputField.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(26)
        }
        
        inputButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(76)
            $0.height.equalTo(30)
        }
        
        underlineView.snp.makeConstraints {  // ✅ 밑줄을 필드 + 버튼 포함하도록 설정
            $0.top.equalTo(inputField.snp.bottom).offset(9)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        categoryContainer.snp.makeConstraints {
            $0.top.equalTo(underlineView.snp.bottom).offset(13)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.greaterThanOrEqualTo(80) // ✅ 최소 높이 설정
        }
        
        categoryTagsContainer.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        reclassifyLabel.snp.makeConstraints {
            $0.top.equalTo(categoryTagsContainer.snp.bottom).offset(25)
            $0.leading.equalToSuperview()
        }
        
        reclassifyButton.snp.makeConstraints {
            $0.top.equalTo(reclassifyLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview()
            $0.width.equalTo(77) // 버튼 너비 명확히 설정
            $0.height.equalTo(13) // 버튼 높이 명확히 설정
        }
        
//        nextButton.snp.makeConstraints {
//            $0.bottom.equalToSuperview().inset(30)
//            $0.leading.trailing.equalToSuperview().inset(20)
//        }
//        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
    }
    
}
