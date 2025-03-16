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
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
//     let closeButton = UIButton().then {
//        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
//        $0.tintColor = .black
//    }
    
     let defaultProfileButton = {
         var configuration = UIButton.Configuration.plain()
         configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
         configuration.image = UIImage(systemName: "person.fill")?.resized(to: CGSize(width: 36, height: 36))
         configuration.imagePadding = 8

         // 폰트 & 텍스트 크기 조절
         let titleFont = UIFont.ptdMediumFont(ofSize: 18)
         let attributedString = NSAttributedString(
             string: "기본 프로필",
             attributes: [
                 .font: titleFont,
                 .foregroundColor: UIColor.black
             ]
         )
         configuration.attributedTitle = AttributedString(attributedString)

         let button = UIButton(configuration: configuration)
         button.contentHorizontalAlignment = .leading
         return button
    }()
    
     let choosePhotoButton = {
         
         var configuration = UIButton.Configuration.plain()
         configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
         configuration.image = UIImage(systemName: "photo")?.resized(to: CGSize(width: 36, height: 36))
         configuration.imagePadding = 8

         // 폰트 & 텍스트 크기 조절
         let titleFont = UIFont.ptdMediumFont(ofSize: 18)
         let attributedString = NSAttributedString(
             string: "사진 선택",
             attributes: [
                 .font: titleFont,
                 .foregroundColor: UIColor.black
             ]
         )
         configuration.attributedTitle = AttributedString(attributedString)

         let button = UIButton(configuration: configuration)
         button.contentHorizontalAlignment = .leading
         return button
    }()
    
    private let dimmedView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
   
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSheet()
    }

    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        
        containerView.addSubviews(defaultProfileButton, choosePhotoButton)
        
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(140)
        }
        
//        closeButton.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(16)
//            make.trailing.equalToSuperview().offset(-16)
//            make.size.equalTo(16)
//        }
        
        defaultProfileButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
    
        choosePhotoButton.snp.makeConstraints { make in
            make.top.equalTo(defaultProfileButton.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        // 처음에는 시트를 화면 밖에 위치시킴
        containerView.transform = CGAffineTransform(translationX: 0, y: 180)
    }
    
    private func setupActions() {
//        closeButton.addTarget(self, action: #selector(dismissBottomSheet), for: .touchUpInside)
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(dimmedTap)
        
        defaultProfileButton.addTarget(self, action: #selector(didTapDefaultProfileButton), for: .touchUpInside)
        choosePhotoButton.addTarget(self, action: #selector(didTapChoosePhotoButton), for: .touchUpInside)
    }
    
    private func showSheet() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.containerView.transform = .identity
            self.dimmedView.alpha = 1.0
        }
    }
    
    private func hideSheet(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.frame.height)
            self.dimmedView.alpha = 0.0
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    // MARK: - Actions
    @objc private func dimmedViewTapped() {
        hideSheet()
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
    
}
