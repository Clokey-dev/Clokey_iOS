//
//  CustomBottomSheetViewController.swift
//  GitTest
//
//  Created by 한금준 on 2/5/25.
//

import UIKit

protocol CustomBottomSheetDelegate: AnyObject {
    func didTapChoosePhoto() // 사진 선택 버튼 클릭
    func didTapDefaultProfile() // 기본 프로필 버튼 클릭
}

final class CustomBottomSheetViewController: UIViewController {
    weak var delegate: CustomBottomSheetDelegate? // Delegate 선언
    
    // MARK: - UI Elements
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단 모서리만 둥글게
    }
    
     let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .black
    }
    
     let defaultProfileButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "person.fill")
        configuration.title = "기본 프로필"
        configuration.imagePadding = 20 // 이미지와 텍스트 간격
        configuration.baseForegroundColor = .black // 텍스트 및 이미지 색상
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 22, bottom: 0, trailing: 0) // 버튼 내부 여백
        $0.configuration = configuration
        $0.contentHorizontalAlignment = .leading // 왼쪽 정렬
    }
    
     let choosePhotoButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "photo")
        configuration.title = "사진 선택"
        configuration.imagePadding = 20 // 이미지와 텍스트 간격
        configuration.baseForegroundColor = .black // 텍스트 및 이미지 색상
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 22, bottom: 0, trailing: 0) // 버튼 내부 여백
        $0.configuration = configuration
        $0.contentHorizontalAlignment = .leading // 왼쪽 정렬
    }
    
   
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActions()
        setupBackgroundTapGesture()
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        showAnimation() // 하단에서 올라오는 애니메이션
    //    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 배경 반투명
        view.addSubview(containerView)
        
        containerView.addSubviews(closeButton, defaultProfileButton, choosePhotoButton)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(185) // 카드 높이
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(16)
        }
        
        defaultProfileButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(48)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-22)
            make.height.equalTo(32)
        }
    
        choosePhotoButton.snp.makeConstraints { make in
            make.top.equalTo(defaultProfileButton.snp.bottom).offset(21)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-22)
            make.height.equalTo(32)
        }
    }
    
    // 화면 배경 터치 감지 추가
    private func setupBackgroundTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.cancelsTouchesInView = false // 버튼 클릭 이벤트도 전달
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) { // containerView 외부를 터치한 경우만 실행
            dismissBottomSheet()
        }
    }
    
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(dismissBottomSheet), for: .touchUpInside)
        defaultProfileButton.addTarget(self, action: #selector(didTapDefaultProfileButton), for: .touchUpInside)
        choosePhotoButton.addTarget(self, action: #selector(didTapChoosePhotoButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func dismissBottomSheet() {
        hideAnimation()
    }
    
    @objc private func didTapDefaultProfileButton() {
        dismiss(animated: true) {
            self.delegate?.didTapDefaultProfile() // Delegate 호출
        }
    }
    
    @objc private func didTapChoosePhotoButton() {
        dismiss(animated: true) {
            self.delegate?.didTapChoosePhoto()
        }
    }
    
    private func hideAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
    
    // MARK: - Animations
    //    private func showAnimation() {
    //        containerView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
    //        UIView.animate(withDuration: 0.3) {
    //            self.containerView.transform = .identity
    //        }
    //    }
    
}
