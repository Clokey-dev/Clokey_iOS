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
    private let thicknessInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("❓ 두께감의 기준이 궁금해요", for: .normal)
        button.setTitleColor(.brown, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
        return button
    }()
    /// 🔹 두께감 기준 설명 뷰 (초기에 숨김)
    private let thicknessInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 8
        view.isHidden = true // 처음엔 숨김
        return view
    }()

    /// 🔹 두께감 설명 라벨
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
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.brown.cgColor
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
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.brown.cgColor
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
        button.backgroundColor = UIColor.brown.withAlphaComponent(0.5)
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

        // 설명 뷰 레이아웃 (초기값)
        thicknessInfoView.snp.makeConstraints {
            $0.top.equalTo(thicknessInfoButton.snp.bottom).offset(0) // 기본 0
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(0)
        }

        // 설명 라벨 배치
        thicknessInfoLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview().inset(10)
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
        
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapInfoButton() {
        let isHidden = thicknessInfoView.isHidden
        thicknessInfoView.isHidden = false // 먼저 숨김 해제

        UIView.animate(withDuration: 0.3, animations: {
            self.thicknessInfoView.snp.updateConstraints {
                $0.height.equalTo(isHidden ? 150 : 0) // 🔥 높이 조정 (펼칠 땐 150, 닫힐 땐 0)
            }
            self.visibilityLabel.snp.updateConstraints {
                $0.top.equalTo(self.thicknessInfoView.snp.bottom).offset(isHidden ? 20 : 30) // 🔥 닫힐 땐 기본 위치 유지
            }
            self.view.layoutIfNeeded() // 🔄 UI 업데이트 반영
        }) { _ in
            self.thicknessInfoView.isHidden = !isHidden // 애니메이션 후 최종 숨김 여부 설정
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
        
        publicButton.backgroundColor = isPublicSelected ? .brown : .clear
        publicButton.setTitleColor(isPublicSelected ? .white : .brown, for: .normal)
        
        privateButton.backgroundColor = isPublicSelected ? .clear : .brown
        privateButton.setTitleColor(isPublicSelected ? .brown : .white, for: .normal)
        
        nextButton.backgroundColor = .brown
        nextButton.isEnabled = true
    }
    
    @objc private func didTapNextButton() {
        print("다음 화면으로 이동")
        // TODO: 다음 화면으로 이동하는 코드 추가
    }
}
