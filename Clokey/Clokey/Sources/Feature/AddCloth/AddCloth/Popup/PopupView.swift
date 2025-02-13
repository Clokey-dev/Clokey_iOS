//
//  PopUpView.swift
//  Clokey
//
//  Created by 한태빈 on 1/21/25.
//

import UIKit
import SnapKit
import Then
class PopupView: UIView {
    // MARK: - UI Components
    var nameLabel = UILabel().then {
        $0.text = "회색 레터링 후드티"
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let publicButton = UIButton().then {
        $0.setImage(UIImage(named: "public_icon"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown600")
    }
    
    var imageView = UIImageView().then {
        $0.image = UIImage(named: "top")
        $0.contentMode = .scaleAspectFit
    }
    
    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
    }

    let categoryButton1 = UIButton().then {
        $0.setTitle("상의", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.backgroundColor = UIColor.clear
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown600")?.cgColor
    }
    
    let frontButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown600")
    }

    let categoryButton2 = UIButton().then {
        $0.setTitle("후드티", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        
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
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.backgroundColor = UIColor(named: "mainBrown600")
        $0.layer.cornerRadius = 5
    }

     let summerButton = UIButton().then {
        $0.setTitle("여름", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.backgroundColor = UIColor.clear
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
    }

     let fallButton = UIButton().then {
        $0.setTitle("가을", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.backgroundColor = UIColor(named: "mainBrown600")
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
    }

     let winterButton = UIButton().then {
        $0.setTitle("겨울", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.backgroundColor = UIColor(named: "mainBrown600")
        $0.layer.cornerRadius = 5
    }
    
    let wearCountLabel: UILabel = {
        let label = UILabel()
        label.text = "착용 횟수"
        label.font = UIFont.ptdMediumFont(ofSize: 16)
        return label
    }()

    let wearCountButton = UIButton().then {
        $0.setTitle("0회", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        
        $0.backgroundColor = UIColor(named: "mainBrown600")
        $0.layer.cornerRadius = 5
    }
    
    let brandLabel: UILabel = {
        let label = UILabel()
        label.text = "브랜드 :"
        label.font = UIFont.ptdMediumFont(ofSize: 16)
        return label
    }()
    
    var brandNameLabel: UILabel = {
        let label = UILabel()
        label.text = "나이키"
        label.font = UIFont.ptdMediumFont(ofSize: 16)
        return label
    }()
    
    let urlLabel: UILabel = {
        let label = UILabel()
        label.text = "url :"
        label.font = UIFont.ptdMediumFont(ofSize: 16)
        return label
    }()
    
    let urlGoButton = UIButton().then {
        let title = "바로가기"
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.mainBrown800,
            .font: UIFont.ptdMediumFont(ofSize: 16)
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        $0.setAttributedTitle(attributedTitle, for: .normal)
        
        $0.backgroundColor = .clear
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
        backgroundColor = .mainBrown50
        layer.cornerRadius = 10
        addSubview(nameLabel)
        addSubview(publicButton)
        addSubview(imageView)
        addSubview(categoryStackView)
        categoryStackView.addArrangedSubview(categoryButton1)
        categoryStackView.addArrangedSubview(frontButton)
        categoryStackView.addArrangedSubview(categoryButton2)
        addSubview(seasonStackView)
        seasonStackView.addArrangedSubview(springButton)
        seasonStackView.addArrangedSubview(summerButton)
        seasonStackView.addArrangedSubview(fallButton)
        seasonStackView.addArrangedSubview(winterButton)
//        addSubview(descriptionLabel)
        addSubview(wearCountLabel)
        addSubview(wearCountButton)
        addSubview(brandLabel)
        addSubview(brandNameLabel)
        addSubview(urlLabel)
        addSubview(urlGoButton)
    }
    // MARK: - Setup Constraints
    private func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.centerX.equalToSuperview()
        }
        publicButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(30)
        }

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(101)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(167)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
        
        frontButton.snp.makeConstraints { make in
            make.size.equalTo(16)
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

        wearCountLabel.snp.makeConstraints { make in
            make.top.equalTo(seasonStackView.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(92)
        }
        
        wearCountButton.snp.makeConstraints { make in
//            make.top.equalTo(seasonStackView.snp.bottom).offset(14)
            make.centerY.equalTo(wearCountLabel)
//            make.leading.equalToSuperview().offset(159)
            make.leading.equalTo(wearCountLabel.snp.trailing).offset(7)
            make.height.equalTo(18)
            make.width.equalTo(39)
        }
        
        brandLabel.snp.makeConstraints { make in
            make.top.equalTo(wearCountLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(92)
        }
        
        brandNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(brandLabel)
            make.leading.equalTo(brandLabel.snp.trailing).offset(5)
        }
        
        urlLabel.snp.makeConstraints { make in
            make.top.equalTo(brandLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(92)
        }
        
        urlGoButton.snp.makeConstraints { make in
            make.centerY.equalTo(urlLabel)
            make.leading.equalTo(urlLabel.snp.trailing).offset(5)
        }
        
//        descriptionLabel.snp.makeConstraints { make in
//            make.top.equalTo(seasonStackView.snp.bottom).offset(14)
//            make.leading.equalToSuperview().offset(92)
//        }

    }
}

