//
//  CustomActionSheetViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import UIKit
import SnapKit
import Then

class CustomActionSheetViewController: UIViewController {
    
    // MARK: - Properties
    
//    private let historyId: Int
    // 임시 historyId
    let historyId: Int = 1
    private let historyService = HistoryService()
    
    // 컨테이너 뷰
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let editButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
        configuration.image = UIImage(named: "edit_icon")?.resized(to: CGSize(width: 36, height: 36))
        configuration.imagePadding = 8

        // 폰트 & 텍스트 크기 조절
        let titleFont = UIFont.ptdMediumFont(ofSize: 18)
        let attributedString = NSAttributedString(
            string: "편집하기",
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

    
    private let saveButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
        configuration.image = UIImage(named: "delete_icon")?.resized(to: CGSize(width: 36, height: 36))
        configuration.imagePadding = 8

        // 폰트 & 텍스트 크기 조절
        let titleFont = UIFont.ptdMediumFont(ofSize: 18)
        let attributedString = NSAttributedString(
            string: "삭제하기",
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
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        
        containerView.addSubview(editButton)
        containerView.addSubview(saveButton)
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(140)
        }
        
        editButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        // 처음에는 시트를 화면 밖에 위치시킴
        containerView.transform = CGAffineTransform(translationX: 0, y: 180)
    }
    
    private func setupActions() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(dimmedTap)
        
        editButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Animation
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
    
    @objc private func shareButtonTapped() {
        print("본문가기 tapped")
        hideSheet()
    }
    
    @objc private func saveButtonTapped() {
        historyService.historyDelete(historyId: historyId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("기록 삭제 성공")
                // TODO: 삭제 성공 후 월 달력 뷰로..
                self.hideSheet()
            case .failure(let error):
                print("기록 삭제 에러: \(error.localizedDescription)")
            }
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
