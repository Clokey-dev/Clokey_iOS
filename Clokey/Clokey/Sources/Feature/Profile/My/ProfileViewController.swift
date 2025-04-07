//
//  ProfileViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/10/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ProfileViewController: UIViewController {
    private let mainView = MainView()
    // MARK: - Properties
    private let profileView = ProfileView()
    private let popUpView = PickPopUpView()
    private var backgroundView: UIView?// 배경 어둡게 하기 위해 선언
    
    private let refreshControl = UIRefreshControl()
    private var loadingOverlay: UIView?
    
    var clokeyId: String = ""
    var followerCount: Int = 0
    var followingCount: Int = 0
    
    var clothId1:Int64?
    var clothId2:Int64?
    var clothId3:Int64?
    
    var url: String = ""
    
    // calendarview
    private let calendarViewController = CalendarViewController()
    
    // MARK: - Lifecycle
    override func loadView() {
        
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.scrollView.contentInsetAdjustmentBehavior = .never
        
        definesPresentationContext = true // 현재 컨텍스트에서 새로운 뷰 표시
        
        profileView.scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        calendarViewController.shouldHideUserNameLabel = true
        addCalendarViewController()
        
        showLoadingOverlay()
        
        loadData()
        setupActions()
        setupPopupActions()
        
        tapProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 네비게이션 바 숨기기 강제 적용
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        additionalSafeAreaInsets.top = 0
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func addCalendarViewController() {
        // 자식 뷰컨트롤러 추가
        addChild(calendarViewController)
        profileView.calendarContainerView.addSubview(calendarViewController.view)
        
        // AutoLayout 설정
        calendarViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 자식 뷰컨트롤러 등록 완료
        calendarViewController.didMove(toParent: self)
    }
    
    deinit {
        // 제거 시 메모리 정리
        calendarViewController.willMove(toParent: nil)
        calendarViewController.view.removeFromSuperview()
        calendarViewController.removeFromParent()
    }
    
    var nickname: String = ""
    var profileImage: String = ""
    var backgroundImage: String = ""
    var bio: String = ""
    var visibility: String = ""
    
    private func tapProfile() {
        // 예: profileImageView가 프로필 이미지 뷰
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        self.profileView.profileImageView.isUserInteractionEnabled = true
        self.profileView.profileImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapProfileImage() {
        let imagePickVC = ImagePickViewController(image: profileImage)
        imagePickVC.modalPresentationStyle = .overFullScreen
        present(imagePickVC, animated: false)
    }
    
    private func loadData() {
        let clokeyId: String = ""
        
        let membersService = MembersService()
        
        membersService.getUserProfile(clokey_id: clokeyId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userProfile):
                DispatchQueue.main.async {
                    self.profileView.usernameLabel.text = userProfile.clokeyId
                    self.clokeyId = userProfile.clokeyId
                    
                    self.profileView.nicknameLabel.text = userProfile.nickname
                    self.nickname = userProfile.nickname
                    
                    self.profileView.writeCountLabel.text = "\(userProfile.recordCount)"
                    self.profileView.followerCountButton.setTitle("\(userProfile.followerCount)", for: .normal)
                    self.followerCount = userProfile.followerCount
                    self.profileView.followingCountButton.setTitle("\(userProfile.followingCount)", for: .normal)
                    self.followingCount = userProfile.followingCount
                    self.profileView.descriptionLabel.text = userProfile.bio
                    self.bio = userProfile.bio
                    self.visibility = userProfile.visibility
                    
                    if let profileImageUrl = userProfile.profileImageUrl,
                       let url = URL(string: profileImageUrl) {
                        self.profileImage = profileImageUrl
                        self.profileView.profileImageView.kf.setImage(with: url)
                    } else {
                        self.profileView.profileImageView.image = UIImage(named: "profile_basic") // 기본 이미지 설정
                    }
                    if let profileBackImageUrl = URL(string: userProfile.profileBackImageUrl) {
                        self.profileView.backgroundImageView.kf.setImage(with: profileBackImageUrl)
                        self.backgroundImage = userProfile.profileBackImageUrl
                    }
                    
                    let clothes = userProfile.clothResults
                    
                    self.profileView.clothesImageView2.isHidden = clothes.isEmpty || clothes.count < 2
                    self.profileView.clothesImageView3.isHidden = clothes.isEmpty || clothes.count < 3
                    
                    // 이미지 설정 (최대 3개)
                    if clothes.count > 0 {
                        if let clothImage = clothes[0].clothImage, let url = URL(string: clothImage) {
                            self.profileView.clothesImageView1.kf.setImage(with: url)
                        } else {
                            self.profileView.clothesImageView1.image = UIImage(named: "beforeaddimage") // 기본 이미지 설정
                        }
                        
                        if let clothId = clothes[0].clothId {
                            self.clothId1 = clothId
                        } else {
                            print("clothId1 값이 nil 입니다.")
                        }
                    }
                    
                    
                    if clothes.count > 1 {
                        if let clothImage = clothes[1].clothImage, let url = URL(string: clothImage) {
                            self.profileView.clothesImageView2.kf.setImage(with: url)
                        } else {
                            self.profileView.clothesImageView2.image = UIImage(named: "beforeaddimage") // 기본 이미지 설정
                        }
                        
                        if let clothId = clothes[1].clothId {
                            self.clothId2 = clothId
                        } else {
                            print("clothId1 값이 nil 입니다.")
                        }
                    }
                    
                    if clothes.count > 2 {
                        if let clothImage = clothes[2].clothImage, let url = URL(string: clothImage) {
                            self.profileView.clothesImageView3.kf.setImage(with: url)
                        } else {
                            self.profileView.clothesImageView3.image = UIImage(named: "beforeaddimage") // 기본 이미지 설정
                        }
                        
                        if let clothId = clothes[2].clothId {
                            self.clothId3 = clothId
                        } else {
                            print("clothId1 값이 nil 입니다.")
                        }
                    }
                    self.hideLoadingOverlay()
                }
            case .failure(let error):
                print("프로필 데이터를 불러오는 데 실패함: \(error.localizedDescription)")
                self.hideLoadingOverlay()
                self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
            }
        }
    }
    
    private func setupActions() {
        profileView.settingButton.addTarget(self, action: #selector(didTapSettingButton), for: .touchUpInside)
        
        profileView.editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        
        profileView.followerCountButton.addTarget(self, action: #selector(didTapFollowerButton), for: .touchUpInside)
        
        profileView.followingCountButton.addTarget(self, action: #selector(didTapFollowingButton), for: .touchUpInside)
        
        profileView.bottomButtonLabel.isUserInteractionEnabled = true
        profileView.bottomArrowIcon.isUserInteractionEnabled = true

        let bottomButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMyClosetButton))
        profileView.bottomButtonLabel.addGestureRecognizer(bottomButtonTapGesture)

        let bottomArrowTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMyClosetButton))
        profileView.bottomArrowIcon.addGestureRecognizer(bottomArrowTapGesture)
    }
    
    @objc private func didTapSettingButton() {
        let settingViewController = SettingViewController()
        navigationController?.pushViewController(settingViewController, animated: true)
    }
    
    @objc private func didTapEditButton() {
        let editProfileViewController = EditProfileViewController()
        editProfileViewController.clokeyId = clokeyId
        editProfileViewController.nickname = nickname
        editProfileViewController.profileImage = profileImage
        editProfileViewController.backgroundImage = backgroundImage
        editProfileViewController.bio = bio
        editProfileViewController.visibility = visibility
        
        navigationController?.pushViewController(editProfileViewController, animated: true)
    }
    
    @objc private func didTapMyClosetButton() {
//        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//            sceneDelegate.navigateToMyCloset()
//        }
        let displayAllVC = DisplayAllViewController()
        navigationController?.pushViewController(displayAllVC, animated: true)
    }
    
    @objc private func didTapFollowerButton() {
        let followListViewController = MyFollowListViewController()
        followListViewController.clokeyId = clokeyId
        followListViewController.followerCount = followerCount
        followListViewController.followingCount = followingCount
        followListViewController.selectedTab = .follower // 팔로워 탭으로 설정
        navigationController?.pushViewController(followListViewController, animated: true)
    }
    
    @objc private func didTapFollowingButton() {
        let followListViewController = MyFollowListViewController()
        followListViewController.clokeyId = clokeyId
        followListViewController.followerCount = followerCount
        followListViewController.followingCount = followingCount
        followListViewController.selectedTab = .following // 팔로잉 탭으로 설정
        followListViewController.hidesBottomBarWhenPushed = false
        navigationController?.pushViewController(followListViewController, animated: true)
    }
    
    private func setupPopupActions() {
        popUpView.deleteButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        profileView.clothesImageView1.isUserInteractionEnabled = true
        profileView.clothesImageView1.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        profileView.clothesImageView2.isUserInteractionEnabled = true
        profileView.clothesImageView2.addGestureRecognizer(tapGesture2)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        profileView.clothesImageView3.isUserInteractionEnabled = true
        profileView.clothesImageView3.addGestureRecognizer(tapGesture3)
    }
    
    // 팝업 닫기 함수
    @objc private func dismissPopup() {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first })
            .first else { return }
        
        //  keyWindow에서 PopUpView 찾기
        if let popUpView = keyWindow.subviews.first(where: { $0 is PickPopUpView }) {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView?.alpha = 0 // 배경도 함께 사라지게 함
                popUpView.alpha = 0
            }) { _ in
                self.backgroundView?.removeFromSuperview() // 배경 제거
                popUpView.removeFromSuperview()
                self.backgroundView = nil // 참조 해제
            }
        }
    }
    
    
    @objc private func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        
        var selectedClothId: Int64?
        
        if tappedImageView == profileView.clothesImageView1 {
            selectedClothId = clothId1
        } else if tappedImageView == profileView.clothesImageView2 {
            selectedClothId = clothId2
        } else if tappedImageView == profileView.clothesImageView3 {
            selectedClothId = clothId3
        }
        
        guard let clothId = selectedClothId else {
            print("clothId 값이 없습니다.")
            return
        }
        
        
        showPopup(with: tappedImageView.image, clothId: clothId)
    }
    
    private func showPopup(with image: UIImage?, clothId: Int64) {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first })
            .first else { return } // keyWindow 설정
        
        // 뒷 배경 어둡게
        let bgView = UIView()
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        bgView.alpha = 0
        keyWindow.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backgroundView = bgView
        
        // 팝업 뷰 생성
        self.popUpView.alpha = 0
        self.popUpView.setImage(image)
        keyWindow.addSubview(self.popUpView)

        self.popUpView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(290)
            make.height.equalTo(489)
        }
        
        // 팝업 애니메이션 효과
        UIView.animate(withDuration: 0.3) {
            bgView.alpha = 1
            self.popUpView.alpha = 1
        }
        
        // closeButton 클릭 시 팝업 닫기 기능 추가
        self.popUpView.deleteButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        bgView.addGestureRecognizer(tap)
        
        let clotehsService = ClothesService()
        
        // checkPopUpClothes API 호출 및 UI 업데이트
        clotehsService.checkPopUpClothes(clothId: clothId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // 응답 데이터를 popUpView에 반영
                    self.popUpView.nameLabel.text = response.name
                    if let imageUrl = URL(string: response.imageUrl) {
                        self.popUpView.imageView.kf.setImage(with: imageUrl)
                    } else {
                        print("유효하지 않은 이미지 URL: \(response.imageUrl)")
                    }
                    if response.visibility == "PUBLIC" {
                        self.popUpView.publicButton.setImage(UIImage(named: "public_icon"), for: .normal)
                    } else {
                        self.popUpView.publicButton.setImage(UIImage(named: "lock_on"), for: .normal)
                    }
                    
                    
                    self.popUpView.categoryButton2.setTitle("\(response.category)", for: .normal)
                    print(response.category)
                    
                    if let categoryName = CategoryModel.getCategoryNameByClothName(response.category) {
                        print(categoryName) // 출력: "상의"
                        self.popUpView.categoryButton1.setTitle("\(categoryName)", for: .normal)
                    }
                    
                    if response.seasons.count > 0 {
                        if response.seasons[0] == "SPRING" {
                            
                            self.popUpView.springButton.setTitleColor(.white, for: .normal)
                            self.popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.springButton.layer.cornerRadius = 5
                            self.popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "SUMMER" {
                            
                            self.popUpView.summerButton.setTitleColor(.white, for: .normal)
                            self.popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.summerButton.layer.cornerRadius = 5
                            self.popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "FALL" {
                            
                            self.popUpView.fallButton.setTitleColor(.white, for: .normal)
                            self.popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.fallButton.layer.cornerRadius = 5
                            self.popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "WINTER" {
                            
                            self.popUpView.winterButton.setTitleColor(.white, for: .normal)
                            self.popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.winterButton.layer.cornerRadius = 5
                            self.popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 1 {
                        if response.seasons[1] == "SPRING" {
                            
                            self.popUpView.springButton.setTitleColor(.white, for: .normal)
                            self.popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.springButton.layer.cornerRadius = 5
                            self.popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "SUMMER" {
                            
                            self.popUpView.summerButton.setTitleColor(.white, for: .normal)
                            self.popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.summerButton.layer.cornerRadius = 5
                            self.popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "FALL" {
                           
                            self.popUpView.fallButton.setTitleColor(.white, for: .normal)
                            self.popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.fallButton.layer.cornerRadius = 5
                            self.popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "WINTER" {
                            
                            self.popUpView.winterButton.setTitleColor(.white, for: .normal)
                            self.popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.winterButton.layer.cornerRadius = 5
                            self.popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 2 {
                        if response.seasons[2] == "SPRING" {
                            
                            self.popUpView.springButton.setTitleColor(.white, for: .normal)
                            self.popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.springButton.layer.cornerRadius = 5
                            self.popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "SUMMER" {
                            
                            self.popUpView.summerButton.setTitleColor(.white, for: .normal)
                            self.popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.summerButton.layer.cornerRadius = 5
                            self.popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "FALL" {
                            
                            self.popUpView.fallButton.setTitleColor(.white, for: .normal)
                            self.popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.fallButton.layer.cornerRadius = 5
                            self.popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "WINTER" {
                            
                            self.popUpView.winterButton.setTitleColor(.white, for: .normal)
                            self.popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.winterButton.layer.cornerRadius = 5
                            self.popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 3 {
                        if response.seasons[3] == "SPRING" {
                            
                            self.popUpView.springButton.setTitleColor(.white, for: .normal)
                            self.popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.springButton.layer.cornerRadius = 5
                            self.popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "SUMMER" {
                        
                            self.popUpView.summerButton.setTitleColor(.white, for: .normal)
                            self.popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.summerButton.layer.cornerRadius = 5
                            self.popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "FALL" {
                            
                            self.popUpView.fallButton.setTitleColor(.white, for: .normal)
                            self.popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.fallButton.layer.cornerRadius = 5
                            self.popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "WINTER" {
                           
                            self.popUpView.winterButton.setTitleColor(.white, for: .normal)
                            self.popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.winterButton.layer.cornerRadius = 5
                            self.popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    self.popUpView.wearCountButton.setTitle("\(response.wearNum)회", for: .normal)
                    self.popUpView.brandNameLabel.text = (response.brand?.isEmpty ?? true) ? "없음" : response.brand
                    self.url = response.clothUrl ?? ""
                    self.updateUrlGoButtonTitle(with: response.clothUrl)
                    
                    
                    // 이미지가 있으면 업데이트
                    if let imageUrl = URL(string: response.imageUrl) {
                        self.popUpView.imageView.kf.setImage(with: imageUrl)
                    }
                    
                    self.popUpView.urlGoButton.addTarget(self, action: #selector(self.urlGoButtonTapped), for: .touchUpInside)
                    
                case .failure(let error):
                    print("팝업 의류 데이터 로드 실패: \(error.localizedDescription)")
                    self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
                }
            }
        }
    }
    
    @objc private func urlGoButtonTapped() {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        // URL 열기
        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                print("Opened URL: \(url)")
            } else {
                print("Failed to open URL: \(url)")
            }
        }
    }
    
    func updateUrlGoButtonTitle(with url: String?) {
        let title = (url?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false) ? "없음" : "바로가기"
        
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.mainBrown800,
            .font: UIFont.ptdMediumFont(ofSize: 12)
        ]

        if title != "없음" {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        popUpView.urlGoButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    @objc private func didPullToRefresh() {
        
        loadData()
        
        // 풀투리프레시 종료 (약간의 딜레이 후)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func showLoadingOverlay() {
        let overlay = UIView()
        overlay.backgroundColor = .white
        view.addSubview(overlay)
        
        // SnapKit을 사용하여 전체화면 제약조건 추가
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingOverlay = overlay
    }
    
    private func hideLoadingOverlay() {
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingOverlay?.alpha = 0
        }) { _ in
            self.loadingOverlay?.removeFromSuperview()
            self.loadingOverlay = nil
        }
    }
}
