//
//  FollowProfileViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/29/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

class FollowProfileViewController: UIViewController, UIGestureRecognizerDelegate {
    private let navBarManager = NavigationBarManager()

    
    // MARK: - Properties
    private let followProfileView = FollowProfileView()
    private let popUpView = PickPopUpView()
    private var backgroundView: UIView?// 배경 어둡게 하기 위해 선언
    
    private let refreshControl = UIRefreshControl()
    private var loadingOverlay: UIView?
    
    private let followCalendarViewController = FollowCalendarViewController()
    
    var followId: String = ""
    var clokey_Id: String = ""
    var followerCount: Int = 0
    var followingCount: Int = 0
    
    var clothId1:Int64?
    var clothId2:Int64?
    var clothId3:Int64?
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        view = followProfileView
    }
    
    init(followId: String) {
        self.followId = followId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        followProfileView.scrollView.contentInsetAdjustmentBehavior = .automatic
 
        setupNavigationBar()
        
        followCalendarViewController.followId = self.followId
        
        definesPresentationContext = true // 현재 컨텍스트에서 새로운 뷰 표시
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        followProfileView.scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        followCalendarViewController.shouldHideUserNameLabel = true
        addCalendarViewController()
        
        showLoadingOverlay()
        
        setupCalendar()
        loadData()
        setupActions()
        setupPopupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setupNavigationBar()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        additionalSafeAreaInsets.top = 0
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func setupNavigationBar() {
        print("setupNavigationBar() 호출됨")
        
        let backButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .mainBrown800
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = clokey_Id
        titleLabel.font = .ptdSemiBoldFont(ofSize: 20)
        titleLabel.textColor = .black
        
        let titleItem = UIBarButtonItem(customView: titleLabel)

        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backButton), titleItem]
        
        navBarManager.setOption(
            to: navigationItem,
            target: self,
            action: #selector(didTapReportButton))
        
        
    }
    
    // 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupCalendar() {
        let calendarVC = FollowCalendarViewController()
        calendarVC.followId = followId
    }
    
    private func addCalendarViewController() {
        followCalendarViewController.followId = followId
        // 자식 뷰컨트롤러 추가
        addChild(followCalendarViewController)
        followProfileView.calendarContainerView.addSubview(followCalendarViewController.view)
        
        // AutoLayout 설정
        followCalendarViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 자식 뷰컨트롤러 등록 완료
        followCalendarViewController.didMove(toParent: self)
    }
    
    deinit {
        // 제거 시 메모리 정리
        followCalendarViewController.willMove(toParent: nil)
        followCalendarViewController.view.removeFromSuperview()
        followCalendarViewController.removeFromParent()
    }
    
    private func loadData() {
        
        let membersService = MembersService()
        
        
        // MARK: - 사용자 정보 받아서 로드하는 API
        membersService.getUserProfile(clokey_id: followId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userProfile):
                DispatchQueue.main.async {

                    self.clokey_Id = userProfile.clokeyId
                    self.followProfileView.nicknameLabel.text = userProfile.nickname
                    self.followProfileView.writeCountLabel.text = "\(userProfile.recordCount)"
                    self.followProfileView.followerCountButton.setTitle("\(userProfile.followerCount)", for: .normal)
                    self.followerCount = userProfile.followerCount
                    self.followProfileView.followingCountButton.setTitle("\(userProfile.followingCount)", for: .normal)
                    self.followingCount = userProfile.followingCount
                    self.followProfileView.descriptionLabel.text = userProfile.bio
                    
                    
                    if let profileImageUrl = userProfile.profileImageUrl,
                       let url = URL(string: profileImageUrl) {
                        self.followProfileView.profileImageView.kf.setImage(with: url)
                    } else {
                        self.followProfileView.profileImageView.image = UIImage(named: "default_background_image") // 기본 이미지 설정
                    }
                    if let profileBackImageUrl = URL(string: userProfile.profileBackImageUrl) {
                        self.followProfileView.backgroundImageView.kf.setImage(with: profileBackImageUrl)
                    }
                    
                    let clothes = userProfile.clothResults
                    
                    self.followProfileView.clothesImageView2.isHidden = clothes.isEmpty || clothes.count < 2
                    self.followProfileView.clothesImageView3.isHidden = clothes.isEmpty || clothes.count < 3
                    
                    // 이미지 설정 (최대 3개)
                    if clothes.count > 0 {
                        if let clothImage = clothes[0].clothImage, let url = URL(string: clothImage) {
                            self.followProfileView.clothesImageView1.kf.setImage(with: url)
                        } else {
                            self.followProfileView.clothesImageView1.image = UIImage(named: "default_cloth_image") // 기본 이미지 설정
                        }
                        
                        if let clothId = clothes[0].clothId {
                            self.clothId1 = clothId
                        } else {
                            print("clothId1 값이 nil 입니다.")
                        }
                    }
                    
                    if clothes.count > 1 {
                        if let clothImage = clothes[1].clothImage, let url = URL(string: clothImage) {
                            self.followProfileView.clothesImageView2.kf.setImage(with: url)
                        } else {
                            self.followProfileView.clothesImageView2.image = UIImage(named: "default_cloth_image") // 기본 이미지 설정
                        }
                        
                        if let clothId = clothes[1].clothId {
                            self.clothId2 = clothId
                        } else {
                            print("clothId1 값이 nil 입니다.")
                        }
                    }
                    
                    if clothes.count > 2 {
                        if let clothImage = clothes[2].clothImage, let url = URL(string: clothImage) {
                            self.followProfileView.clothesImageView3.kf.setImage(with: url)
                        } else {
                            self.followProfileView.clothesImageView3.image = UIImage(named: "default_cloth_image") // 기본 이미지 설정
                        }
                        
                        if let clothId = clothes[2].clothId {
                            self.clothId3 = clothId
                        } else {
                            print("clothId1 값이 nil 입니다.")
                        }
                    }
                    
                    guard let isFollowing = userProfile.isFollowing else {
                        self.followProfileView.followButton.setTitle("팔로우", for: .normal)
                        self.followProfileView.followButton.backgroundColor = .mainBrown800
                        self.followProfileView.followButton.setTitleColor(.white, for: .normal)
                        self.followProfileView.followButton.layer.borderColor = UIColor.mainBrown800.cgColor
                        self.followProfileView.followButton.layer.borderWidth = 1
                        return
                    }
                    
                    // 팔로우
                    if isFollowing {
                        self.followProfileView.followButton.setTitle("팔로잉", for: .normal)
                        self.followProfileView.followButton.backgroundColor = .white
                        self.followProfileView.followButton.setTitleColor(.black, for: .normal)
                        self.followProfileView.followButton.layer.borderColor = UIColor.mainBrown800.cgColor
                        self.followProfileView.followButton.layer.borderWidth = 1
                    } else {
                        self.followProfileView.followButton.setTitle("팔로우", for: .normal)
                        self.followProfileView.followButton.backgroundColor = .mainBrown800
                        self.followProfileView.followButton.setTitleColor(.white, for: .normal)
                        self.followProfileView.followButton.layer.borderColor = UIColor.mainBrown800.cgColor
                        self.followProfileView.followButton.layer.borderWidth = 1
                    }
                    
                    if userProfile.visibility == "PRIVATE" {
                        self.followProfileView.updateClothesPrivateState(isPrivate: true)
                        self.followProfileView.updateCalendarPrivateState(isPrivate: true)
//                        self.followProfileView.followPrivateState(isPrivate: true)
                    } else {
                        self.followProfileView.updateClothesPrivateState(isPrivate: false)
                        self.followProfileView.updateCalendarPrivateState(isPrivate: false)
//                        self.followProfileView.followPrivateState(isPrivate: false)
                    }
                    
                    self.setupNavigationBar()
                    self.hideLoadingOverlay()
                }
            case .failure(let error):
                print("프로필 데이터를 불러오는 데 실패함: \(error.localizedDescription)")
                self.hideLoadingOverlay()
            }
        }
    }
    
    private func setupActions() {
        
        followProfileView.followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        followProfileView.blockButton.addTarget(self, action: #selector(didTapBlockButton), for: .touchUpInside)
        followProfileView.followerCountButton.addTarget(self, action: #selector(didTapFollowerButton), for: .touchUpInside)
        followProfileView.followingCountButton.addTarget(self, action: #selector(didTapFollowingButton), for: .touchUpInside)
        
        followProfileView.bottomButtonLabel.isUserInteractionEnabled = true
        followProfileView.bottomArrowIcon.isUserInteractionEnabled = true
        
        let bottomButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFollowClothButton))
        followProfileView.bottomButtonLabel.addGestureRecognizer(bottomButtonTapGesture)
        
        let bottomArrowTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFollowClothButton))
        followProfileView.bottomArrowIcon.addGestureRecognizer(bottomArrowTapGesture)
    }

    
    @objc private func didTapReportButton(_ sender: UIButton) {
        let actionSheet = FollowProfileActionViewController(clokeyId: followId)
        actionSheet.delegate = self
        actionSheet.modalPresentationStyle = .overFullScreen
        present(actionSheet, animated: false)
    }
    
    // MARK: - 팔로우 버튼 이벤트
    @objc private func didTapFollowButton() {
        let currentTitle = followProfileView.followButton.title(for: .normal)
        let followService = MembersService()
        
        followService.followUser(clokeyId: followId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if currentTitle == "팔로잉" {
                        // 팔로잉 -> 팔로우 (언팔로우 상태로 변경)
                        self.followProfileView.followButton.setTitle("팔로우", for: .normal)
                        self.followProfileView.followButton.backgroundColor = .mainBrown800
                        self.followProfileView.followButton.setTitleColor(.white, for: .normal)
                        self.followProfileView.followButton.layer.borderColor = UIColor.mainBrown800.cgColor
                        self.followProfileView.followButton.layer.borderWidth = 1
                    } else {
                        // 팔로우 -> 팔로잉 (팔로우 상태로 변경)
                        self.followProfileView.followButton.setTitle("팔로잉", for: .normal)
                        self.followProfileView.followButton.backgroundColor = .white
                        self.followProfileView.followButton.setTitleColor(.black, for: .normal)
                        self.followProfileView.followButton.layer.borderColor = UIColor.mainBrown800.cgColor
                        self.followProfileView.followButton.layer.borderWidth = 1
                        
                        // 팔로우할 때만 알림 보내기
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.sendFollowNotification(clokeyId: self.followId)
                        }
                    }
                case .failure(let error):
                    print("🚨 팔로우/언팔로우 요청 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func didTapBlockButton() {
        followProfileView.blockButton(isBlock: false)
        followProfileView.updateCloseAccount(isClosed: false)
    }
    
    
    // 팔로우 알림 보내기
    private func sendFollowNotification(clokeyId: String) {
        let notificationService = NotificationService()
        
        notificationService.notificationFollow(clokeyId: clokeyId) { result in
            switch result {
            case .success:
                print("팔로우 알림 전송 성공")
            case .failure(let error):
                print("팔로우 알림 전송 실패: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func didTapFollowClothButton() {
        let displayAllVC = DisplayAllViewController()
        displayAllVC.clokeyId = followId
        navigationController?.pushViewController(displayAllVC, animated: true)
    }
    
    
    @objc private func didTapFollowerButton() {
        let followListViewController = YourFollowListViewController()
        followListViewController.selectedTab = .follower // 팔로워 탭으로 설정
        followListViewController.followerCount = followerCount
        followListViewController.followingCount = followingCount
        followListViewController.clokeyId = self.clokey_Id
        navigationController?.pushViewController(followListViewController, animated: true)
    }
    
    @objc private func didTapFollowingButton() {
        let followListViewController = YourFollowListViewController()
        followListViewController.selectedTab = .following // 팔로잉 탭으로 설정
        followListViewController.followerCount = followerCount
        followListViewController.followingCount = followingCount
        followListViewController.clokeyId = self.clokey_Id
        navigationController?.pushViewController(followListViewController, animated: true)
    }
    
    private func setupPopupActions() {
        popUpView.deleteButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        followProfileView.clothesImageView1.isUserInteractionEnabled = true
        followProfileView.clothesImageView1.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        followProfileView.clothesImageView2.isUserInteractionEnabled = true
        followProfileView.clothesImageView2.addGestureRecognizer(tapGesture2)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        followProfileView.clothesImageView3.isUserInteractionEnabled = true
        followProfileView.clothesImageView3.addGestureRecognizer(tapGesture3)
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
        
        if tappedImageView == followProfileView.clothesImageView1 {
            selectedClothId = clothId1
        } else if tappedImageView == followProfileView.clothesImageView2 {
            selectedClothId = clothId2
        } else if tappedImageView == followProfileView.clothesImageView3 {
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
        let popUpView = PickPopUpView()
        popUpView.alpha = 0
        popUpView.setImage(image)
        keyWindow.addSubview(popUpView)
        
        popUpView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(290)
            make.height.equalTo(489)
        }
        
        // 팝업 애니메이션 효과
        UIView.animate(withDuration: 0.3) {
            bgView.alpha = 1
            popUpView.alpha = 1
        }
        
        // closeButton 클릭 시 팝업 닫기 기능 추가
        popUpView.deleteButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        bgView.addGestureRecognizer(tap)
        
        let clotehsService = ClothesService()
        
        //  checkPopUpClothes API 호출 및 UI 업데이트
        clotehsService.checkPopUpClothes(clothId: clothId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // 응답 데이터를 popUpView에 반영
                    popUpView.nameLabel.text = response.name
                    if let imageUrl = URL(string: response.imageUrl) {
                        popUpView.imageView.kf.setImage(with: imageUrl)
                    } else {
                        print("유효하지 않은 이미지 URL: \(response.imageUrl)")
                    }
                    if response.visibility == "PUBLIC" {
                        popUpView.publicButton.setImage(UIImage(named: "lock_off"), for: .normal)
                    } else {
                        popUpView.publicButton.setImage(UIImage(named: "lock_on"), for: .normal)
                    }
                    
                    
                    popUpView.categoryButton2.setTitle("\(response.category)", for: .normal)
                    print(response.category)
                    
                    if let categoryName = CategoryModel.getCategoryNameByClothName(response.category) {
                        print(categoryName) // 출력: "상의"
                        popUpView.categoryButton1.setTitle("\(categoryName)", for: .normal)
                    }
                    
                    if response.seasons.count > 0 {
                        if response.seasons[0] == "SPRING" {
                            //                                configureButton(popUpView.springButton, title: "봄")
                            popUpView.springButton.setTitleColor(.white, for: .normal)
                            popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 1 {
                        if response.seasons[1] == "SPRING" {
                            //                                configureButton(popUpView.springButton, title: "봄")
                            popUpView.springButton.setTitleColor(.white, for: .normal)
                            popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 2 {
                        if response.seasons[2] == "SPRING" {
                            //                                configureButton(popUpView.springButton, title: "봄")
                            popUpView.springButton.setTitleColor(.white, for: .normal)
                            popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 3 {
                        if response.seasons[3] == "SPRING" {
                            //                                configureButton(popUpView.springButton, title: "봄")
                            popUpView.springButton.setTitleColor(.white, for: .normal)
                            popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    //                    popUpView.wearCountButton.titleLabel?.text = "\(response.wearNum)"
                    popUpView.wearCountButton.setTitle("\(response.wearNum)회", for: .normal)
                    popUpView.brandNameLabel.text = (response.brand?.isEmpty ?? true) ? "지정 없음" : response.brand
                    self.url = response.clothUrl ?? ""
                    
                    if response.clothUrl == nil {
                        popUpView.urlGoButton.titleLabel?.text = "지정 안됨"
                    }
                    
                    
                    // 이미지가 있으면 업데이트
                    if let imageUrl = URL(string: response.imageUrl) {
                        popUpView.imageView.kf.setImage(with: imageUrl)
                    }
                    
                    popUpView.urlGoButton.addTarget(self, action: #selector(self.urlGoButtonTapped), for: .touchUpInside)
                    
                case .failure(let error):
                    print("팝업 의류 데이터 로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var url: String = ""
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
        
        overlay.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top) // 네비게이션 바 아래부터 적용
            make.leading.trailing.bottom.equalToSuperview()
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

extension FollowProfileViewController: FollowProfileActionDelegate {
    func didReportUser() {
        print("사용자가 신고됨")
        let bottomSheetVC = CustomBottomSheetViewController()
        bottomSheetVC.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            let accountRepoVC = CustomReportViewController(clokeyId: self.followId)
            self.navigationController?.pushViewController(accountRepoVC, animated: true)
        }
    }

    func didBlockUser() {
        print("사용자가 차단됨")
        
        
//        guard let viewModel = viewModel else { return }
        let clokeyId = self.followId

        print("\(clokeyId) 는 ?? ")

        // 액션 시트 닫기
        dismiss(animated: false) { [weak self] in
            // Alert 표시
            let alert = UIAlertController(
                title: "사용자 차단",
                message: "정말 이 사용자를 차단하시겠습니까?",
                preferredStyle: .alert
            )

            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "차단", style: .destructive) { _ in
                self?.blockMember(clokeyId: clokeyId)
            }

            alert.addAction(cancelAction)
            alert.addAction(confirmAction)

            // 현재 뷰 컨트롤러에서 Alert 띄우기
            if let topViewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?
                .rootViewController {
                topViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // 차단 API
    private func blockMember(clokeyId: String) {
        let membersService = MembersService()
        
        membersService.blockOrUnblock(clokeyId: clokeyId) { result in
            switch result {
            case .success:
                print("\(clokeyId) 차단 성공")
                DispatchQueue.main.async {
//                    if let navigationController = UIApplication.shared.connectedScenes
//                        .compactMap({ $0 as? UIWindowScene })
//                        .flatMap({ $0.windows })
//                        .first(where: { $0.isKeyWindow })?
//                        .rootViewController as? UINavigationController {
//                        
//                        navigationController.popViewController(animated: true)
//                    } else {
//                        print("네비게이션 컨트롤러를 찾을 수 없음")
//                    }
                    self.followProfileView.blockButton(isBlock: true)
                    self.followProfileView.updateCloseAccount(isClosed: true)
                }
            case .failure(let error):
                print("차단 실패: \(error.localizedDescription)")
            }
        }
    }
}

