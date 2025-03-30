//
//  ClosetPopupView.swift
//  Clokey
//
//  Created by 한태빈 on 1/21/25.
//

import UIKit
import SnapKit
import Then

class ClosetPopupView: UIView {
    // MARK: - UI Components
    let nameLabel = UILabel().then {
        $0.text = "" // API 데이터로 업데이트되도록 초기에는 빈 문자열
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let publicButton = UIButton().then {
        $0.setImage(UIImage(named: "public_icon"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
    }
    
    let imageView = UIImageView().then {
        $0.image = UIImage(named: "top")
        $0.contentMode = .scaleAspectFit
    }

    let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
    }
    
    let categoryButton1 = UIButton().then { button in
        var config = UIButton.Configuration.filled()
        config.title = ""
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.ptdMediumFont(ofSize: 12)
            return outgoing
        }
        
        config.background.strokeColor = UIColor(named: "mainBrown600") ?? .brown
        config.background.strokeWidth = 1
        config.background.cornerRadius = 4
        
        button.configuration = config
    }


    
    let frontButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
    }
    
    
    let categoryButton2 = UIButton().then { button in
        var config = UIButton.Configuration.filled()
        config.title = ""
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.ptdMediumFont(ofSize: 12)
            return outgoing
        }
        
        config.background.strokeColor = UIColor(named: "mainBrown600") ?? .brown
        config.background.strokeWidth = 1
        config.background.cornerRadius = 4
        
        button.configuration = config
    }

    
    let seasonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
    }
    
    let springButton = UIButton().then {
        $0.setTitle("봄", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 5
    }

    let summerButton = UIButton().then {
        $0.setTitle("여름", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.backgroundColor = UIColor.clear
        $0.layer.cornerRadius = 5
    }

    let fallButton = UIButton().then {
        $0.setTitle("가을", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 5

    }

    let winterButton = UIButton().then {
        $0.setTitle("겨울", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 5

        
    }
    
    // MARK: - Grouped Info UI Components
    
    let wearCountLabel: UILabel = {
        let label = UILabel()
        label.text = "착용횟수"
        label.font = UIFont.ptdMediumFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    let wearCountButton = UIButton().then {
        $0.setTitle("", for: .normal) // 초기 빈값
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 5
    }
    
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
        label.text = "url"
        label.font = UIFont.ptdMediumFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    let urlGoButton = UIButton().then {
        let title = ""
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
    
    // Group horizontal stack views
    private lazy var wearStackView = UIStackView(arrangedSubviews: [wearCountLabel, wearCountButton]).then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
        
    }
    
    private lazy var brandStackView = UIStackView(arrangedSubviews: [brandLabel, brandNameLabel]).then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
    }
    
    private lazy var urlStackView = UIStackView(arrangedSubviews: [urlLabel, urlGoButton]).then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
    }
    
    // Vertical stack view to hold all grouped info
    private lazy var infoStackView = UIStackView(arrangedSubviews: [wearStackView, brandStackView, urlStackView]).then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .center
    }
    
    let optionButton = UIButton().then {
        $0.setImage(UIImage(named: "dot3_icon"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
    }
    
    let leftArrowButton = UIButton().then {
        $0.setImage(UIImage(named: "left_circle_icon"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
    }
    
    let rightArrowButton = UIButton().then {
        $0.setImage(UIImage(named: "right_circle_icon"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
    }
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "erase_icon"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
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
        addSubview(imageView)
        addSubview(publicButton)
        addSubview(optionButton)
        addSubview(categoryStackView)
        categoryStackView.addArrangedSubview(categoryButton1)
        categoryStackView.addArrangedSubview(frontButton)
        categoryStackView.addArrangedSubview(categoryButton2)
        addSubview(seasonStackView)
        addSubview(seasonStackView)
        addSubview(wearCountButton)
        seasonStackView.addArrangedSubview(springButton)
        seasonStackView.addArrangedSubview(summerButton)
        seasonStackView.addArrangedSubview(fallButton)
        seasonStackView.addArrangedSubview(winterButton)

        
        // 그룹화한 정보 스택뷰 추가
        addSubview(infoStackView)
        
        addSubview(leftArrowButton)
        addSubview(rightArrowButton)
        addSubview(closeButton)
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(26)
            make.trailing.equalToSuperview().offset(-25)
            make.size.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(62)
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(138)
            make.height.equalTo(183)
        }
        
        leftArrowButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top).offset(80)
            make.leading.equalToSuperview().offset(25)
            make.size.equalTo(24)
        }
        
        rightArrowButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top).offset(80)
            make.trailing.equalToSuperview().offset(-25)
            make.size.equalTo(24)
        }
        
        publicButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top).offset(10)
            make.trailing.equalTo(imageView.snp.trailing).offset(-10)
            make.size.equalTo(20)
        }
        
        optionButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.trailing.equalToSuperview().offset(-25)
            make.size.equalTo(24)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        categoryButton1.snp.makeConstraints { make in
//            make.width.equalTo(43)
            make.height.equalTo(22)
        }
        
        frontButton.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
        
        categoryButton2.snp.makeConstraints { make in
            //            make.width.equalTo(54)
            make.height.equalTo(22)
        }
        
        wearCountButton.snp.makeConstraints { make in
            make.width.equalTo(39)
            make.height.equalTo(18)
        }
        
        seasonStackView.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom).offset(15)
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
        }
        
        // infoStackView 제약 조건
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(seasonStackView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }

        // 각 서브 스택뷰의 높이를 22로 고정 (팝업창 UI 변경 - 조금 더 수정 반영)
        wearStackView.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        brandStackView.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        urlStackView.snp.makeConstraints { make in
            make.height.equalTo(22)
        }

    }
}
