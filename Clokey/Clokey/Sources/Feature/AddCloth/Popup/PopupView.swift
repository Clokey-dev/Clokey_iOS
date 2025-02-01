import UIKit
import SnapKit
import Then

class PopupView: UIView {
    
    // MARK: - UI Components
    
    private let popupCardView = UIView().then {
        $0.backgroundColor = UIColor(named: "mainBrown50") // ✅ 배경색 변경
        $0.layer.cornerRadius = 30
        $0.clipsToBounds = true
    }
    private let dateLabel = UILabel().then {
        $0.text = "2025.01.18 (SAT)"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    let nameLabel = UILabel().then {
        $0.text = "회색 울 코트"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    let imageView = UIImageView().then {
        $0.image = UIImage(named: "coat")
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
    }

    private let categoryButton1 = UIButton().then {
        $0.setTitle("상의", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        $0.backgroundColor = .clear // ✅ 배경 없애기 (피그마 스타일)
        $0.layer.borderWidth = 1 // ✅ 테두리 추가
        $0.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor // ✅ 테두리 색 지정
        $0.layer.cornerRadius = 4
        $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10) // ✅ 내부 패딩 추가
    }
    
    private let categoryButton2 = UIButton().then {
        $0.setTitle("후드티", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        $0.backgroundColor = UIColor(named: "mainBrown200")
        $0.layer.cornerRadius = 4
    }

    private let categorySeparator = UILabel().then {
        $0.text = ">"
        $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        $0.textColor = .black
    }

    private let seasonLabel = UILabel().then {
        $0.text = "착용 계절"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .black
    }

    private let seasonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8 // ✅ 간격을 8로 설정
        $0.alignment = .center
        $0.distribution = .equalSpacing // ✅ 동일한 간격 유지
    }

    private let wearCountLabel = UILabel().then {
        $0.text = "착용 횟수"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .black
    }

    private let wearCountButton = UIButton().then {
        $0.setTitle("N회", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 5
    }

    private let visibilityLabel = UILabel().then {
        $0.text = "공개 범위"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .black
    }

    private let visibilityButton = UIButton().then {
        $0.setTitle("공개", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 5
    }

    let brandLabel = UILabel().then {
        let text = "브랜드 : 나이키"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: (text as NSString).range(of: "나이키"))
        $0.attributedText = attributedString
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }

    private let urlLabel = UILabel().then {
        $0.text = "URL :"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .black
    }
   

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(popupCardView)

        popupCardView.addSubview(dateLabel)
        popupCardView.addSubview(nameLabel)
        popupCardView.addSubview(imageView)
        popupCardView.addSubview(categoryStackView)
        popupCardView.addSubview(seasonLabel)
        popupCardView.addSubview(seasonStackView)
        popupCardView.addSubview(wearCountLabel)
        popupCardView.addSubview(wearCountButton)
        popupCardView.addSubview(visibilityLabel)
        popupCardView.addSubview(visibilityButton)
        popupCardView.addSubview(brandLabel)
        popupCardView.addSubview(urlLabel)

        categoryStackView.addArrangedSubview(categoryButton1)
        categoryStackView.addArrangedSubview(categorySeparator)
        categoryStackView.addArrangedSubview(categoryButton2)

        ["봄", "여름", "가을", "겨울"].forEach {
            let button = UIButton()
            button.setTitle($0, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            button.backgroundColor = UIColor(named: "mainBrown800")
            button.layer.cornerRadius = 5
            seasonStackView.addArrangedSubview(button)
        }
    }

    private func setupConstraints() {
        popupCardView.snp.makeConstraints {
            $0.width.equalTo(290)
            $0.height.equalTo(508)
            $0.center.equalToSuperview()
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(34)
            $0.centerX.equalToSuperview()
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(180)
            $0.height.equalTo(220)
        }

        categoryStackView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
        }

        seasonLabel.snp.makeConstraints {
            $0.top.equalTo(categoryStackView.snp.bottom).offset(11.79)
            $0.leading.equalToSuperview().offset(20)
        }

        seasonStackView.snp.makeConstraints {
            $0.top.equalTo(seasonLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        wearCountLabel.snp.remakeConstraints {
            $0.top.equalTo(seasonStackView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20) // ✅ 모든 요소 동일한 leading 적용
        }

        wearCountButton.snp.remakeConstraints {
            $0.centerY.equalTo(wearCountLabel) // ✅ 같은 높이 맞추기
            $0.leading.equalTo(wearCountLabel.snp.trailing).offset(8) // ✅ 버튼과 간격 맞추기
            $0.width.equalTo(50)
            $0.height.equalTo(30)
        }

        visibilityLabel.snp.remakeConstraints {
            $0.top.equalTo(wearCountButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20) // ✅ 동일한 leading 적용
        }

        visibilityButton.snp.remakeConstraints {
            $0.centerY.equalTo(visibilityLabel)
            $0.leading.equalTo(visibilityLabel.snp.trailing).offset(8)
            $0.width.equalTo(50)
            $0.height.equalTo(30)
        }
        // "브랜드 : 나이키" 위치 설정
        brandLabel.snp.makeConstraints {
            $0.top.equalTo(visibilityButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }

        // "URL :" 위치 설정
        urlLabel.snp.makeConstraints {
            $0.top.equalTo(brandLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(20)
        }

        // popupCardView 높이 증가
        popupCardView.snp.remakeConstraints {
            $0.width.equalTo(290)
            $0.height.equalTo(570) // 기존 508에서 증가
            $0.center.equalToSuperview()
        }

        // 2️⃣ popupCardView 높이 늘리기 (마지막 요소까지 잘 보이도록)
        popupCardView.snp.remakeConstraints {
            $0.width.equalTo(290)
            $0.height.equalTo(570) // 기존 508에서 증가
            $0.center.equalToSuperview()
        }
    }
}
