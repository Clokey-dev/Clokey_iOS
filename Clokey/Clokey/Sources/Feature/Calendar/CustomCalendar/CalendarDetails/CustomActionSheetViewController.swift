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
    
    
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let shareButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        configuration.title = "편집하기"
        configuration.baseForegroundColor = .black
        
        let button = UIButton(configuration: configuration)
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    private let saveButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        configuration.title = "삭제하기"
        configuration.baseForegroundColor = .black
        
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
        
        containerView.addSubview(shareButton)
        containerView.addSubview(saveButton)
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(140)
        }
        
        shareButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(shareButton.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        // 처음에는 시트를 화면 밖에 위치시킴
        containerView.transform = CGAffineTransform(translationX: 0, y: 140)
    }
    
    private func setupActions() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(dimmedTap)
        
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
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
