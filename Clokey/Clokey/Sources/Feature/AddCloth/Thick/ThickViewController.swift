//
//  ThickViewController.swift
//  Clokey
//
//  Created by 소민준 on 2/1/25.
//

import UIKit
import SnapKit

class ThickViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 🔹 네비게이션 바
    private let customNavBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    /// 🔹 뒤로가기 버튼
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    /// 🔹 타이틀 ("옷 추가")
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "옷 추가"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    /// 🔹 두께감 설정 제목
    private let thicknessTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "두께감을 설정해주세요."
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    
    /// 🔹 두께감 설명 버튼
    /// 🔹 두께감 설명 버튼 (❓ 대신 아이콘 사용)
    /// 🔹 두께감 설명 버튼 (텍스트만 유지)
    private let thicknessInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("두께감의 기준이 궁금해요", for: .normal)
        button.setTitleColor(.black, for: .normal) // ✅ 글자 색상이 보이도록 설정
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left // ✅ 텍스트가 왼쪽 정렬되도록 설정
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal) // ✅ 크기 줄어들지 않도록 설정
        button.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
        return button
    }()

    /// 🔹 질문 아이콘 (별도로 추가)
    private let questionIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "question_citrcle_icon")
        imageView.contentMode = .scaleAspectFit
        
        // ✅ Hugging Priority 설정 → 버튼보다 먼저 크기를 유지하게 함
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return imageView
    }()
    /// 🔹 버튼 + 아이콘을 포함하는 StackView
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6 // ✅ 아이콘과 텍스트 간격 조정
        stack.alignment = .center
        return stack
    }()
    /// 🔹 두께감 기준 설명 뷰 (초기에 숨김)
    /// 🔹 두께감 기준 설명 뷰 (초기에 숨김)
    /// ✅ 두께감 기준 설명 뷰 (초기에 숨김)
    private let thicknessInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "mainBrown50") // ✅ 배경색 적용
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()

    /// ✅ 두께감 설명 라벨
    private let thicknessInfoLabel: UILabel = {
        let label = UILabel()
        label.text = """
        0: 나시, 반팔, 반바지
        1: 린넨 셔츠, 면 슬랙스
        2: 기본 맨투맨, 얇은 니트
        3: 기모 있는 후드티, 두꺼운 청자켓
        4: 울 코트, 양털 후리스
        5: 두꺼운 오리털 패딩, 롱패딩
        """
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        label.backgroundColor = .clear // ✅ 배경색을 없애서 부모 뷰 색상 유지
        return label
    }()
    /// 🔹 두께감 슬라이더 (ThickSlider 사용)
    private let thickSlider: ThickSlider = {
        let slider = ThickSlider()
        slider.isContinuous = false // 값 변경을 단계적으로
        return slider
    }()
    
    /// 🔹 공개 여부 라벨
    private let visibilityLabel: UILabel = {
        let label = UILabel()
        label.text = "옷 공개여부 *"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    
    
    /// 🔹 공개 버튼
    private let publicButton: UIButton = {
        let button = UIButton()
        button.setTitle("공개", for: .normal)
        button.setTitleColor(.brown, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didTapVisibilityButton(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 🔹 비공개 버튼
    private let privateButton: UIButton = {
        let button = UIButton()
        button.setTitle("비공개", for: .normal)
        button.setTitleColor(.brown, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didTapVisibilityButton(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 🔹 다음 버튼
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainBrown400
        button.layer.cornerRadius = 10
        button.isEnabled = false // 기본적으로 비활성화
        button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return button
    }()
    
    // 공개 여부 선택 상태
    private var isPublicSelected: Bool? {
        didSet { updateVisibilitySelection() }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
       
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(customNavBar)
        customNavBar.addSubview(backButton)
        customNavBar.addSubview(titleLabel)
        
        view.addSubview(thicknessTitleLabel)
        view.addSubview(thicknessInfoButton)
        view.addSubview(thickSlider)
        
        view.addSubview(visibilityLabel)
        view.addSubview(publicButton)
        view.addSubview(privateButton)
        
        view.addSubview(nextButton)
        view.addSubview(thicknessInfoView)
        thicknessInfoView.addSubview(thicknessInfoLabel)
        // ✅ StackView에 아이콘과 버튼 추가
        infoStackView.addArrangedSubview(questionIcon)
        infoStackView.addArrangedSubview(thicknessInfoButton)

        // ✅ StackView를 뷰에 추가
        view.addSubview(infoStackView)

        // ✅ StackView 오토레이아웃 설정
    
        infoStackView.snp.makeConstraints {
                $0.top.equalTo(thickSlider.snp.bottom).offset(24)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.lessThanOrEqualToSuperview().offset(-20) // ✅ 너무 넓어지지 않도록 설정
            }
        // ✅ 버튼이 자동으로 줄어들지 않도록 설정
        thicknessInfoButton.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(180) // ✅ 최소 180px 너비 설정 (고정 아님)
        }

        // ✅ questionIcon의 너비를 고정하지 않고 자연스럽게 조정되도록 설정!
        questionIcon.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.width.equalTo(24)// ✅ 높이만 설정
        }
        // 설명 뷰 레이아웃 (초기값)
        // 설명 뷰 레이아웃 (초기값)
        thicknessInfoView.snp.makeConstraints {
            $0.top.equalTo(thicknessInfoButton.snp.bottom).offset(0) // 기본 0
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(0) // ✅ 처음엔 높이 0
        }
        // 설명 라벨 배치
        thicknessInfoLabel.snp.makeConstraints {
            $0.top.equalTo(thicknessInfoView.snp.top).offset(10)
            $0.bottom.equalTo(thicknessInfoView.snp.bottom).offset(-10).priority(750) // ✅ 우선순위 낮추기
        }
        
        // 네비게이션 바 레이아웃
        customNavBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalTo(customNavBar)
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(customNavBar)
        }
        
        // 두께감 설정 타이틀
        thicknessTitleLabel.snp.makeConstraints {
            $0.top.equalTo(customNavBar.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(20)
        }
        thicknessInfoButton.snp.makeConstraints {
            $0.top.equalTo(thickSlider.snp.bottom).offset(24) // 🔥 슬라이더 아래로 이동
            $0.leading.equalToSuperview().offset(20)
           
        }

        
        // ThickSlider 배치
        // ThickSlider 배치 (타이틀 아래)
        thickSlider.snp.makeConstraints {
            $0.top.equalTo(thicknessTitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        
        // 공개 여부 라벨
        visibilityLabel.snp.makeConstraints {
            $0.top.equalTo(thicknessInfoView.snp.bottom).offset(30) // 🔥 설명 뷰가 나오면 자동으로 내려가게 설정
            $0.leading.equalToSuperview().offset(20)
        }
        
        publicButton.snp.makeConstraints {
            $0.top.equalTo(visibilityLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(80)
            $0.height.equalTo(40)
        }
        
        publicButton.snp.makeConstraints {
            $0.top.equalTo(visibilityLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(80)
            $0.height.equalTo(40)
        }

        privateButton.snp.makeConstraints {
            $0.top.equalTo(visibilityLabel.snp.bottom).offset(15)
            $0.leading.equalTo(publicButton.snp.trailing).offset(10)
            $0.width.equalTo(80)
            $0.height.equalTo(40)
        }
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        thicknessInfoButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        thicknessInfoButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapInfoButton() {
        let isHidden = thicknessInfoView.isHidden
        thicknessInfoView.isHidden = false // ✅ 먼저 숨김 해제 (필수)

        UIView.animate(withDuration: 0.3, animations: {
            self.thicknessInfoView.snp.updateConstraints {
                $0.height.equalTo(isHidden ? 150 : 0) // ✅ 토글 방식으로 높이 변경
            }
            self.view.layoutIfNeeded() // ✅ 애니메이션 적용
        }) { _ in
            self.thicknessInfoView.isHidden = !isHidden // ✅ 애니메이션 후 최종 숨김 여부 설정
        }
    }
    
    @objc private func didTapVisibilityButton(_ sender: UIButton) {
        if sender == publicButton {
            isPublicSelected = true
        } else {
            isPublicSelected = false
        }
    }
    
    private func updateVisibilitySelection() {
        guard let isPublicSelected = isPublicSelected else { return }
        
        publicButton.backgroundColor = isPublicSelected ? .mainBrown800 : .clear
        publicButton.setTitleColor(isPublicSelected ? .white : .mainBrown800, for: .normal)
        
        privateButton.backgroundColor = isPublicSelected ? .clear : .mainBrown800
        privateButton.setTitleColor(isPublicSelected ? .mainBrown800 : .white, for: .normal)
        
        nextButton.backgroundColor = .mainBrown800
        nextButton.isEnabled = true
    }
    
    
    @objc private func didTapNextButton() {
        let popupVC = PopupViewController()
        popupVC.modalPresentationStyle = .fullScreen // ✅ 전체 화면 모달
        navigationController?.pushViewController(popupVC, animated: true)    }
}
