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
        $0.text = ""
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.lineBreakMode = .byCharWrapping
    }
    
    let deleteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
    }
    
    var imageView = UIImageView().then {
        $0.image = UIImage(named: "top")
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }
    
    let publicButton = UIButton().then {
        $0.setImage(UIImage(named: "public_icon"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
    }
    
    let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
    }
    
    let categoryButton1 = UIButton().then {
        $0.setTitle("", for: .normal)
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
        $0.setTitle("", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        
        $0.backgroundColor = UIColor.clear
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown600")?.cgColor
        $0.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        $0.sizeToFit()
    }
    
    let seasonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
    }
    
    let springButton = UIButton().then {
        $0.setTitle("봄", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.backgroundColor = UIColor.clear
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown600")?.cgColor
    }
    
    let summerButton = UIButton().then {
        $0.setTitle("여름", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.backgroundColor = UIColor.clear
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown600")?.cgColor
    }
    
    let fallButton = UIButton().then {
        $0.setTitle("가을", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.backgroundColor = UIColor.clear
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown600")?.cgColor
    }
    
    let winterButton = UIButton().then {
        $0.setTitle("겨울", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.backgroundColor = UIColor.clear
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown600")?.cgColor
    }
    
    
    let wearCountLabel: UILabel = {
        let label = UILabel()
        label.text = "착용 횟수"
        label.font = UIFont.ptdMediumFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    let wearCountButton = UIButton().then {
        $0.setTitle("0회", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 5
    }
    
    let brandContainerView = UIView()
    
    let brandLabel: UILabel = {
        let label = UILabel()
        label.text = "브랜드"
        label.font = UIFont.ptdMediumFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    var brandNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.ptdMediumFont(ofSize: 12)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    let urlLabel: UILabel = {
        let label = UILabel()
        label.text = "URL"
        label.font = UIFont.ptdMediumFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    let urlGoButton = UIButton().then {
        let title = "바로가기"
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.mainBrown800,
            .font: UIFont.ptdMediumFont(ofSize: 12)
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
        backgroundColor = UIColor(red: 255/255, green: 254/255, blue: 252/255, alpha: 1)
        layer.cornerRadius = 30
        addSubview(nameLabel)
        addSubview(deleteButton)
        addSubview(imageView)
        addSubview(publicButton)
        addSubview(categoryStackView)
        categoryStackView.addArrangedSubview(categoryButton1)
        categoryStackView.addArrangedSubview(frontButton)
        categoryStackView.addArrangedSubview(categoryButton2)
        addSubview(seasonStackView)
        seasonStackView.addArrangedSubview(springButton)
        seasonStackView.addArrangedSubview(summerButton)
        seasonStackView.addArrangedSubview(fallButton)
        seasonStackView.addArrangedSubview(winterButton)
        addSubview(wearCountLabel)
        addSubview(wearCountButton)
        addSubview(brandContainerView)
        brandContainerView.addSubview(brandLabel)
        brandContainerView.addSubview(brandNameLabel)
        addSubview(urlLabel)
        addSubview(urlGoButton)
    }
    // MARK: - Setup Constraints
    private func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(55)
            make.centerX.equalToSuperview()
        }
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(30)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(138)
            make.height.equalTo(183)
        }
        
        publicButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top).offset(10)
            make.trailing.equalTo(imageView.snp.trailing).offset(-10)
            make.size.equalTo(20)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(17)
            make.centerX.equalToSuperview()
        }
        
        categoryButton1.snp.makeConstraints { make in
            make.width.equalTo(43)
            make.height.equalTo(22)
        }
        
        frontButton.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
        
        categoryButton2.snp.makeConstraints { make in
            //            make.width.equalTo(54)
            make.height.equalTo(22)
        }
        
        seasonStackView.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom).offset(17)
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
            make.top.equalTo(seasonStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(92)
        }
        
        wearCountButton.snp.makeConstraints { make in
            make.centerY.equalTo(wearCountLabel)
            make.leading.equalTo(wearCountLabel.snp.trailing).offset(10)
            make.height.equalTo(18)
            make.width.equalTo(39)
        }
        
        brandContainerView.snp.makeConstraints { make in
            make.top.equalTo(wearCountLabel.snp.bottom).offset(24)
            make.leading.greaterThanOrEqualToSuperview().offset(20) // 고정이 아닌 최소값 설정 (왼쪽 이동 가능)
            make.trailing.lessThanOrEqualToSuperview().offset(-20) // 너무 길어지지 않도록 제한
            make.centerX.equalToSuperview() //  중앙 정렬 유지 (왼쪽으로 이동할 수 있도록)
        }

        brandLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview() // brandContainerView 내부의 왼쪽 고정
            make.centerY.equalToSuperview()
        }

        brandNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(brandLabel.snp.trailing).offset(23) // 브랜드명은 브랜드 라벨 오른쪽에서 시작
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview() // 최대 길이 제한
        }
        
        urlLabel.snp.makeConstraints { make in
            make.top.equalTo(brandContainerView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(92)
        }
        
        urlGoButton.snp.makeConstraints { make in
            make.centerY.equalTo(urlLabel)
            make.leading.equalTo(urlLabel.snp.trailing).offset(32)
        }
        
    }
    // 이미지 설정 메서드 추가
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
}
