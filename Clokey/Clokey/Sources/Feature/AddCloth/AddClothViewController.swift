import UIKit
import SnapKit


class AddClothViewController: UIViewController {
    
    
    
    // MARK: - UI Components
    
    /// 🔹 커스텀 네비게이션 바
    private let customNavBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    /// 🔹 뒤로 가기 버튼
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
    }()

    /// 🔹 화면 타이틀 ("옷 추가")
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "옷 추가"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    /// 🔹 텍스트 필드 + 버튼을 감싸는 컨테이너 (밑줄 포함)
    private let inputContainer: UIView = {
        let view = UIView()
        return view
    }()

    /// 🔹 입력 필드 (보더 제거)
    /// 🔹 입력 필드 (보더 제거)
    private let inputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "옷의 이름을 입력해주세요"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .none  // ✅ 기본 보더 제거
        textField.textColor = .black
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged) // ✅ 텍스트 변경 감지
        return textField
    }()

    /// 🔹 "옷의 이름을 입력해주세요!" 타이틀
    private let SmallTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "옷의 이름을 입력해주세요!"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()

    /// 🔹 설명 문구 ("옷 이름을 설정하고 입력 버튼을 누르면 카테고리 자동 분류가 이루어집니다.")
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "옷 이름을 설정하고 입력 버튼을 누르면 카테고리 자동 분류가 이루어집니다."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()
    /// 🔹 입력 버튼 (밑줄 포함)
    
    private let inputButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("입력", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        // ✅ 버튼 스타일 수정
        btn.backgroundColor = .clear  // ✅ 기본 배경 투명
        btn.layer.borderWidth = 1      // ✅ 테두리 추가
        btn.layer.borderColor = UIColor.black.cgColor // ✅ 테두리 색상 설정
        btn.layer.cornerRadius = 10    // ✅ 둥근 모서리 설정
        btn.clipsToBounds = true       // ✅ 클립 적용

        btn.addTarget(self, action: #selector(handleInput), for: .touchUpInside)
        return btn
    }()

    /// 🔹 텍스트 필드 + 입력 버튼 아래의 밑줄
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black  // ✅ 검정색 밑줄
        return view
    }()

    /// 🔹 카테고리 분류 UI 컨테이너 (기본적으로 숨김)
    private let categoryContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    /// 🔹 카테고리 태그 정렬 StackView (ex: 상의 > 후드티)
    private let categoryTagsContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()

    /// 🔹 "카테고리 재분류" 안내 텍스트
    private let reclassifyLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리 재분류를 원하시나요?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()

    /// 🔹 "직접 분류하기" 버튼 (밑줄 스타일)
    private let reclassifyButton: UIButton = {
        let btn = UIButton()
        let title = NSAttributedString(
            string: "직접 분류하기",
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: UIColor.brown]
        )
        btn.setAttributedTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.addTarget(self, action: #selector(handleReclassify), for: .touchUpInside)
        return btn
    }()

    /// 🔹 "다음" 버튼 (초기 비활성화)
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.backgroundColor = UIColor.mainBrown50
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = true // ✅ 여기서 직접 설정
        button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return button
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
    }
    
    private func setupLayout() {
        // 네비게이션 바 추가
        view.addSubview(customNavBar)
        customNavBar.addSubview(backButton)
        customNavBar.addSubview(titleLabel)
        view.addSubview(SmallTitleLabel)
           view.addSubview(descriptionLabel)
        
        view.addSubview(inputContainer)
        inputContainer.addSubview(inputField)
        inputContainer.addSubview(inputButton)
        inputContainer.addSubview(underlineView)  // ✅ 밑줄 추가

        view.addSubview(categoryContainer)
        view.addSubview(nextButton)

        SmallTitleLabel.snp.makeConstraints {
                $0.top.equalTo(customNavBar.snp.bottom).offset(19) // 네비게이션 바 아래 20pt
                $0.leading.trailing.equalToSuperview().inset(20)
            }
        //설명
        descriptionLabel.snp.makeConstraints {
               $0.top.equalTo(SmallTitleLabel.snp.bottom).offset(8) // 타이틀 아래 10pt
               $0.leading.trailing.equalToSuperview().inset(20)
           }
        // ✅ 네비게이션 바 레이아웃
        customNavBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(11) // Status Bar 아래 11pt
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44) // 네비게이션
        }

        // ✅ 뒤로 가기 버튼 레이아웃
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalTo(customNavBar)
            $0.width.height.equalTo(24)
        }

        // ✅ 타이틀 UILabel 레이아웃
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        // ✅ 입력 필드 컨테이너 레이아웃 (밑줄 포함)
        inputContainer.snp.makeConstraints {
                $0.top.equalTo(descriptionLabel.snp.bottom).offset(30) // 설명 아래 30pt
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(40)
        }

        inputField.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
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

        // ✅ 카테고리 UI 레이아웃
        categoryContainer.snp.makeConstraints {
            $0.top.equalTo(inputContainer.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        categoryContainer.addSubview(categoryTagsContainer)
        categoryContainer.addSubview(reclassifyLabel)
        categoryContainer.addSubview(reclassifyButton)

        categoryTagsContainer.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        reclassifyLabel.snp.makeConstraints {
            $0.top.equalTo(categoryTagsContainer.snp.bottom).offset(10)
            $0.leading.equalToSuperview()
        }

        reclassifyButton.snp.makeConstraints {
            $0.top.equalTo(reclassifyLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview()
        }
    }
    @objc private func didTapNextButton() {
        let weatherVC = WeatherChooseViewController()

        if let navController = self.navigationController {
            navController.pushViewController(weatherVC, animated: true)
        } else {
            weatherVC.modalPresentationStyle = .fullScreen
            self.present(weatherVC, animated: true, completion: nil)
        }
    }
    // MARK: - Action Handlers
    @objc private func handleInput() {
        guard let text = inputField.text, !text.isEmpty else {
            print("❌ 입력 필드가 비어 있음")
            return
        }

        categoryTagsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let category1 = makeCategoryTag(title: "상의")
        let separator = makeSeparator()
        let category2 = makeCategoryTag(title: "후드티")

        categoryTagsContainer.addArrangedSubview(category1)
        categoryTagsContainer.addArrangedSubview(separator)
        categoryTagsContainer.addArrangedSubview(category2)

        categoryContainer.isHidden = false
        nextButton.isEnabled = true
        view.layoutIfNeeded()
    }

    @objc private func handleReclassify() {
        let categoryVC = CategorySelectionViewController()
        navigationController?.pushViewController(categoryVC, animated: true)
    }

    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            inputButton.backgroundColor = UIColor(named: "mainBrown800") // ✅ 텍스트 있으면 색 변경
            inputButton.setTitleColor(.white, for: .normal)
            inputButton.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor // ✅ 테두리 색도 변경
        } else {
            inputButton.backgroundColor = .clear // ✅ 텍스트 없으면 투명
            inputButton.layer.borderColor = UIColor.black.cgColor// ✅ 기본 테두리 색 유지
            inputButton.setTitleColor(UIColor.black, for: .normal)// ✅ 기본 글 색 유지
        }
    }
    
}

    private func makeCategoryTag(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.brown, for: .normal)
        button.titleLabel?.font = UIFont.ptdBoldFont(ofSize: 16)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.pointOrange800.cgColor
        button.layer.cornerRadius = 5
        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 14, bottom: 3, right: 14) // ✅ 내부 여백 추가
        return button
    }

    private func makeSeparator() -> UILabel {
        let label = UILabel()
        label.text = ">"
        label.textColor = .brown
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }


