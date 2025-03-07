//
//  AccountReportView.swift
//  Report
//
//  Created by 한금준 on 3/5/25.
//

import UIKit
import Then

class AccountReportView: UIView {
    
    private let infoTitle = UILabel().then {
        $0.text = "계정 정보"
        $0.font = .ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .black
    }
    
    private let infoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let infoImageContainer = UIView().then {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    private let infoImage = UIImageView().then {
        $0.image = UIImage(named: "dd")
        $0.contentMode = .scaleAspectFit
    }
    
    private let infoTextStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private let infoIdLabel = UILabel().then {
        $0.text = "아이디"
        $0.textColor = .black
        $0.font = .ptdMediumFont(ofSize: 14)
    }
    
    private let infoNameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.textColor = .black
        $0.font = .ptdRegularFont(ofSize: 12)
    }
    
    private let divideLine = UIView().then {
        $0.backgroundColor = .lightGray
    }
    
    private let reportTitle = UILabel().then {
        $0.text = "신고 사유"
        $0.font = .ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .black
    }
    
    private let checkbox1 = CheckBox()
    private let checkbox1Title = UILabel().then {
        $0.text = "허위 계정 또는 사칭입니다"
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    private let checkbox2 = CheckBox()
    let checkbox2Title = UILabel().then {
        $0.text = "스팸 홍보 및 도배 계정입니다"
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    
    let checkbox2InfoContainer = UILabel().then {
        $0.backgroundColor = UIColor(red: 255/255, green: 248/255, blue: 235/255, alpha: 1)
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
//        $0.isHidden = true
    }
    
    private let checkbox2InfoText1 = UILabel().then {
        $0.text = "• 광고성 메시지를 지속적으로 보내는 계정"
        $0.font = .ptdRegularFont(ofSize: 12)
        $0.textColor = .black
    }
    private let checkbox2InfoText2 = UILabel().then {
        $0.text = "• 홍보 목적의 프로필 (상업적 링크 다수 포함)"
        $0.font = .ptdRegularFont(ofSize: 12)
        $0.textColor = .black
    }
    private let checkbox2InfoText3 = UILabel().then {
        $0.text = "• 동일한 내용의 글을 반복적으로 게시하는 계정"
        $0.font = .ptdRegularFont(ofSize: 12)
        $0.textColor = .black
    }
    
     let checkbox3 = CheckBox()
    private let checkbox3Title = UILabel().then {
        $0.text = "부적절한 프로필 정보입니다."
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    private let checkbox4 = CheckBox()
    private let checkbox4Title = UILabel().then {
        $0.text = "기타 (직접 입력 가능)"
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    
    let completeButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.backgroundColor = UIColor.pointOrange800
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.layer.cornerRadius = 10
//        $0.isEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    private func setupView() {
        backgroundColor = .white
        
        addSubview(infoTitle)
        addSubview(infoStackView)
        infoStackView.addArrangedSubview(infoImageContainer)
        infoImageContainer.addSubview(infoImage)
        infoStackView.addArrangedSubview(infoTextStackView)
        infoTextStackView.addArrangedSubview(infoIdLabel)
        infoTextStackView.addArrangedSubview(infoNameLabel)
        addSubview(divideLine)
        addSubview(reportTitle)
        addSubview(checkbox1)
        addSubview(checkbox1Title)
        addSubview(checkbox2)
        addSubview(checkbox2Title)
        addSubview(checkbox2InfoContainer)
        checkbox2InfoContainer.addSubview(checkbox2InfoText1)
        checkbox2InfoContainer.addSubview(checkbox2InfoText2)
        checkbox2InfoContainer.addSubview(checkbox2InfoText3)
        addSubview(checkbox3)
        addSubview(checkbox3Title)
        addSubview(checkbox4)
        addSubview(checkbox4Title)
        addSubview(completeButton)
    }
    
    private func setupConstraint() {
        infoTitle.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(18)
            $0.leading.equalToSuperview().offset(20)
        }
        
        infoStackView.snp.makeConstraints {
            $0.top.equalTo(infoTitle.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(46)
        }
        
        infoImageContainer.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        infoImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        infoTextStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
        }
        
        infoIdLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        infoNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
        }
        
        divideLine.snp.makeConstraints {
            $0.top.equalTo(infoStackView.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        reportTitle.snp.makeConstraints {
            $0.top.equalTo(divideLine.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
        
        checkbox1.snp.makeConstraints {
            $0.top.equalTo(reportTitle.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(20)
        }
        
        checkbox1Title.snp.makeConstraints {
            $0.top.equalTo(checkbox1.snp.top)
            $0.leading.equalTo(checkbox1.snp.trailing).offset(11)
        }
        
        checkbox2.snp.makeConstraints {
            $0.top.equalTo(checkbox1.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        checkbox2Title.snp.makeConstraints {
            $0.top.equalTo(checkbox2.snp.top)
            $0.leading.equalTo(checkbox1.snp.trailing).offset(11)
        }
        
        checkbox2InfoContainer.snp.makeConstraints {
            $0.top.equalTo(checkbox2Title.snp.bottom).offset(8)
            $0.leading.equalTo(checkbox2Title.snp.leading)
            $0.width.equalTo(324)
//            $0.height.equalTo(86)
            $0.height.equalTo(0)
        }
        
        checkbox2InfoText1.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(10)
        }
        checkbox2InfoText2.snp.makeConstraints {
            $0.top.equalTo(checkbox2InfoText1.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
        }
        checkbox2InfoText3.snp.makeConstraints {
            $0.top.equalTo(checkbox2InfoText2.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
        }
        
        checkbox3.snp.makeConstraints {
            $0.top.equalTo(checkbox2InfoContainer.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        checkbox3Title.snp.makeConstraints {
            $0.top.equalTo(checkbox3.snp.top)
            $0.leading.equalTo(checkbox1.snp.trailing).offset(11)
        }
        
        checkbox4.snp.makeConstraints {
            $0.top.equalTo(checkbox3.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        checkbox4Title.snp.makeConstraints {
            $0.top.equalTo(checkbox4.snp.top)
            $0.leading.equalTo(checkbox1.snp.trailing).offset(11)
        }
        
        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(54)
            $0.width.equalTo(353)
        }
    }
    
}
