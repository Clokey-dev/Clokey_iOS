//
//  PickPopUpView.swift
//  Clokey
//
//  Created by 한금준 on 2/6/25.
//

import UIKit
import SnapKit
import Then

class PickPopUpView: UIView {

    // MARK: - UI Components
    var nameLabel = UILabel().then {
        $0.text = "회색 레터링 후드티"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let deleteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown600")
    }
    
    var imageView = UIImageView().then {
        $0.image = UIImage(named: "top")
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
    }

    let categoryButton1 = UIButton().then {
        $0.setTitle("상의", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        $0.backgroundColor = UIColor.clear
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown600")?.cgColor
    }


    let categoryButton2 = UIButton().then {
        $0.setTitle("후드티", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        $0.backgroundColor = UIColor.clear
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown600")?.cgColor
    }
    
     let seasonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
    }
    
     let springButton = UIButton().then {
        $0.setTitle("봄", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        $0.backgroundColor = UIColor(named: "mainBrown600")
        $0.layer.cornerRadius = 5
    }

     let summerButton = UIButton().then {
        $0.setTitle("여름", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        $0.backgroundColor = UIColor.clear
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
    }

     let fallButton = UIButton().then {
        $0.setTitle("가을", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        $0.backgroundColor = UIColor(named: "mainBrown600")
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
    }

     let winterButton = UIButton().then {
        $0.setTitle("겨울", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        $0.backgroundColor = UIColor(named: "mainBrown600")
        $0.layer.cornerRadius = 5
    }

    
    let descriptionLabel = UILabel().then {
        let fullText = """
        착용 횟수
        
        브랜드 : 나이키
        
        url : 바로가기
        """
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // "url : 바로가기" 부분에 밑줄 추가
        if let range = fullText.range(of: "바로가기") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        }
        
        $0.attributedText = attributedString
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.numberOfLines = 0
        $0.textColor = .black
    }

    let wearCountButton = UIButton().then {
        $0.setTitle("0회", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        $0.backgroundColor = UIColor(named: "mainBrown600")
        $0.layer.cornerRadius = 5
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
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor(red: 255/255, green: 248/255, blue: 235/255, alpha: 1)
        layer.cornerRadius = 10
        addSubview(nameLabel)
        addSubview(deleteButton)
        addSubview(imageView)
        addSubview(categoryStackView)
        categoryStackView.addArrangedSubview(categoryButton1)
        categoryStackView.addArrangedSubview(categoryButton2)
        addSubview(seasonStackView)
        seasonStackView.addArrangedSubview(springButton)
        seasonStackView.addArrangedSubview(summerButton)
        seasonStackView.addArrangedSubview(fallButton)
        seasonStackView.addArrangedSubview(winterButton)
        addSubview(wearCountButton)
        addSubview(descriptionLabel)
    }
    // MARK: - Setup Constraints
    private func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(58)
            make.centerX.equalToSuperview()
        }
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(30)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(167)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
        
        categoryButton1.snp.makeConstraints { make in
            make.width.equalTo(43)
            make.height.equalTo(22)
        }
        
        
        categoryButton2.snp.makeConstraints { make in
            make.width.equalTo(54)
            make.height.equalTo(22)
        }
        
        seasonStackView.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        springButton.snp.makeConstraints { make in
            make.width.equalTo(31)
            make.height.equalTo(18)
            
        }
        
        [summerButton, fallButton, winterButton].forEach { button in
            button.snp.makeConstraints { make in
                make.width.equalTo(41)
                make.height.equalTo(18)
            }
        } //스택 내 버튼 한번에 처리

        wearCountButton.snp.makeConstraints { make in
            make.top.equalTo(seasonStackView.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(159)
            make.height.equalTo(18)
            make.width.equalTo(39)
        }
        
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(seasonStackView.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(92)
        }

    }
    // 이미지 설정 메서드 추가
        func setImage(_ image: UIImage?) {
            imageView.image = image
        }

}
