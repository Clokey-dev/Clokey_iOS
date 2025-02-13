//
//  AgreementDetailViewController.swift
//  Clokey
//
//  Created by 소민준 on 1/18/25.
//

import UIKit

class AgreementDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let agreementTitle: String
    private let agreementContent: String // ✅ 내용을 받을 프로퍼티 추가
    
    // MARK: - UI Components
    private lazy var contentTextView: UITextView = { // UILabel → UITextView로 변경 (스크롤 지원)
        let textView = UITextView()
        textView.text = agreementContent // ✅ 초기화 시 내용 주입
        textView.font = .systemFont(ofSize: 16)
        textView.isEditable = false
        textView.textColor = .black
        return textView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    init(title: String, content: String) {
        self.agreementTitle = title
        self.agreementContent = content // 내용 저장
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // 제목 레이블
        let titleLabel = UILabel()
        titleLabel.text = agreementTitle
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        view.addSubview(titleLabel)
        
        // 닫기 버튼
        view.addSubview(closeButton)
        
        // 내용 텍스트뷰
        view.addSubview(contentTextView) // ✅ UILabel 대신 UITextView 사용
        
        // 제약조건
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16) // ✅ 하단까지 확장
        }
    }
    
    // MARK: - Actions
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}
