//
//  SettingViewController.swift
//  Clokey
//
//  Created by 한금준 on 2/4/25.
//

import UIKit

class SettingViewController: UIViewController, UIGestureRecognizerDelegate {
    private let navBarManager = NavigationBarManager()
    
    private let settingView = SettingView()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        updateUI()
        setupActions()
        
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    // 네비게이션 설정
    private func setupNavigationBar() {
        let backButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .mainBrown800
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "설정"
        titleLabel.font = .ptdSemiBoldFont(ofSize: 20)
        titleLabel.textColor = .black
        
        let titleItem = UIBarButtonItem(customView: titleLabel)
        
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backButton), titleItem]
    }
    
    // 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func updateUI() {
        let membersService = MembersService()
        
        membersService.getAgreedTerms{ [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let agreedTerms):
                DispatchQueue.main.async {
                    if agreedTerms.socialType == "KAKAO" {
                        self.settingView.kakaoImage.image = UIImage(named: "kakao_icon")
                    } else {
                        self.settingView.kakaoImage.image = UIImage(named: "apple_logo2")
                    }
                    
                    self.settingView.emailLabel.text = agreedTerms.email
                    
                    if let marketingTerm = agreedTerms.terms.first(where: { $0.termId == 4 }) {
                        self.settingView.marketingSwitch.isOn = marketingTerm.agreed
                    }
                    
                    if let pushTerm = agreedTerms.terms.first(where: { $0.termId == 5 }) {
                        self.settingView.pushSwitch.isOn = pushTerm.agreed
                    }
                    
                    self.settingView.versionInfoLabel.text = agreedTerms.appVersion
                }
            case .failure(let error):
                print("설정 UI 업데이트 실패: \(error.localizedDescription)")
                self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
            }
            
        }
    }
    
    
    private func setupActions() {
        settingView.marketingSwitch.addTarget(self, action: #selector(didTapAgreeTerms), for: .valueChanged)
        settingView.pushSwitch.addTarget(self, action: #selector(didTapAgreeTerms), for: .valueChanged)
        
        setupButtonActions(for: settingView.inquiryContainer, action: #selector(didTapInquiry))
        setupButtonActions(for: settingView.logoutContainer, action: #selector(didTapLogout))
        setupButtonActions(for: settingView.deleteContainer, action: #selector(didTapDeleteAccount))
        // 좋아요기록
        setupButtonActions(for: settingView.LikedHistoryContainer, action: #selector(didTapLikedHistory))
        // 내가 쓴 댓글
        setupButtonActions(for: settingView.HistoryCommentContainer, action: #selector(didTapHistoryComment))
        setupButtonActions(for: settingView.blokedAccountContainer, action: #selector(didTapBlockButton))

    }
    
    private func setupButtonActions(for container: UIView, action: Selector) {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        button.addTarget(self, action: action, for: .touchUpInside) // 터치가 끝날 때 실행
        container.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 컨테이너 전체를 덮도록 설정
        }
    }
    // 터치 시작 시 배경색 변경
    @objc private func buttonTouchDown(_ sender: UIButton) {
        sender.superview?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    }
    
    // 터치 종료 시 배경색 복귀
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            sender.superview?.backgroundColor = .white
        }
    }
    
    @objc private func didTapAgreeTerms() {
        let marketingState = settingView.marketingSwitch.isOn
        let pushState = settingView.pushSwitch.isOn
        
        let requestData = OptionalTermAgreeRequestDTO(
            terms: [
                OptionalTermAgreeRequestDTO.Terms(termId: 4, agreed: marketingState),
                OptionalTermAgreeRequestDTO.Terms(termId: 5, agreed: pushState)
            ]
        )
        
        MembersService().optionalTermAgree(data: requestData) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(" 선택 동의 상태 변경 성공: \(response)")
                    
                    //  서버 응답을 UI에 반영
                    if let marketingTerm = response.terms.first(where: { $0.termId == 4 }) {
                        self.settingView.marketingSwitch.isOn = marketingTerm.agreed
                    }
                    
                    if let pushTerm = response.terms.first(where: { $0.termId == 5 }) {
                        self.settingView.pushSwitch.isOn = pushTerm.agreed
                    }
                case .failure(let error):
                    print("🚨 선택 동의 상태 변경 실패: \(error.localizedDescription)")
                    
                    //  요청 실패 시 스위치 상태 복구
                    self.settingView.marketingSwitch.isOn.toggle()
                    self.settingView.pushSwitch.isOn.toggle()
                    self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
                }
            }
        }
    }
    
    @objc private func didTapInquiry() {
        let imageUrl: String? = "http://pf.kakao.com/_amHbn"
        print("문의하기")
        guard let urlString = imageUrl, let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        // URL 열기
        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                print("Opened URL: \(urlString)")
            } else {
                print("Failed to open URL: \(urlString)")
            }
        }
    }
    
    // 로그아웃
    @objc private func didTapLogout() {
        
        let alert = UIAlertController(
            title: "로그아웃",
            message: "정말 로그아웃 하시겠습니까?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "확인", style: .destructive) { _ in
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "FCMToken") // 디바이스 토큰 삭제
            KeychainHelper.shared.delete(forKey: "accessToken")
            KeychainHelper.shared.delete(forKey: "refreshToken")
            
            
            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
                print("SceneDelegate를 찾을 수 없습니다.")
                return
            }
            
            sceneDelegate.switchToLogin()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func didTapDeleteAccount() {
        
        let deleteAccountViewController = DeleteAccountViewController()
        deleteAccountViewController.modalPresentationStyle = .fullScreen
        present(deleteAccountViewController, animated: true, completion: nil)
    }
    
    @objc private func didTapLikedHistory() {
        let likeHistoryVC = LikeHistoryViewController()
        if let navigationController = navigationController {
            navigationController.pushViewController(likeHistoryVC, animated: true)
        } else {
            likeHistoryVC.modalPresentationStyle = .fullScreen
            present(likeHistoryVC, animated: true, completion: nil)
        }
    }
    
    @objc private func didTapHistoryComment() {
        let HistoryCommentVC = CommentHistoryViewController()
        if let navigationController = navigationController {
            navigationController.pushViewController(HistoryCommentVC, animated: true)
        } else {
            HistoryCommentVC.modalPresentationStyle = .fullScreen
            present(HistoryCommentVC, animated: true, completion: nil)
        }
    }
    
    @objc private func didTapBlockButton() {
        let blockVC = BlockUserViewController()
        navigationController?.pushViewController(blockVC, animated: true)
    }
       
}
