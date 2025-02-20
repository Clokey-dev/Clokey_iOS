//
//  NewsViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/8/25.
//

// 완

import UIKit
import Then
import SnapKit
import Kingfisher

class NewsViewController: UIViewController {
    
    private var pageViewController: UIPageViewController!
    private let newsView = NewsView()
    private var recommandNewsSlides: [RecommandNewsSlideModel] = []
    private var currentIndex: Int = 0
    
    private lazy var pageControl: UIPageControl = UIPageControl().then {
        $0.numberOfPages = totalImages()
        $0.currentPage = currentIndexValue()
        $0.pageIndicatorTintColor = .lightGray
        $0.currentPageIndicatorTintColor = .black
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = newsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        
        setupDummyData()
        setupPageViewController()
        setupPageControl()
        
        setupFriendClothesBottomLabelTap()
        setupFollowingCalendarBottomLabelTap()
        
        fetchHotData()
        fetchFriendClothes()
        
        setupActions()
        
        fetchFriendCalendar()
    }
    
    
    var followId: String = ""
    
    @objc private func handleProfileIconTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView,
              let clokeyId = imageView.accessibilityIdentifier else {
            print("🚨 클로키 ID를 찾을 수 없음")
            return
        }
        
        let followProfileVC = FollowProfileViewController()
        followProfileVC.followId = clokeyId
        self.navigationController?.pushViewController(followProfileVC, animated: true)
    }
    
    private func fetchHotData() {
        let homeService = HomeService()
        
        homeService.fetchGetIssuesData { result in
            switch result {
            case .success(let responseDTO):
                DispatchQueue.main.async {
                    let peopleItems = responseDTO.people
                    let peopleCount = peopleItems.count
                    
                    print("Hot People 데이터 개수: \(peopleCount)")
                    
                    if peopleCount >= 1 {
                        self.newsView.hotAccountImageView1.kf.setImage(with: URL(string: peopleItems[0].imageUrl))
                        self.newsView.hotAccountProfileIcon1.kf.setImage(with: URL(string: peopleItems[0].profileImage))
                        self.newsView.hotAccountProfileName1.text = peopleItems[0].clokeyId
                        
                        self.newsView.hotAccountProfileIcon1.accessibilityIdentifier = peopleItems[0].clokeyId
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileIconTap))
                        self.newsView.hotAccountProfileIcon1.isUserInteractionEnabled = true
                        self.newsView.hotAccountProfileIcon1.addGestureRecognizer(tapGesture)
                        
                    } else {
                        self.newsView.hotAccountImageView1.image = nil
                        self.newsView.hotAccountProfileIcon1.image = nil
                        self.newsView.hotAccountProfileName1.text = ""
                    }
                    
                    if peopleCount >= 2 {
                        self.newsView.hotAccountImageView2.kf.setImage(with: URL(string: peopleItems[1].imageUrl))
                        self.newsView.hotAccountProfileIcon2.kf.setImage(with: URL(string: peopleItems[1].profileImage))
                        self.newsView.hotAccountProfileName2.text = peopleItems[1].clokeyId
                        
                        self.newsView.hotAccountProfileIcon2.accessibilityIdentifier = peopleItems[1].clokeyId
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileIconTap))
                        self.newsView.hotAccountProfileIcon2.isUserInteractionEnabled = true
                        self.newsView.hotAccountProfileIcon2.addGestureRecognizer(tapGesture)
                        
                        
                    } else {
                        self.newsView.hotAccountImageView2.image = nil
                        self.newsView.hotAccountProfileIcon2.image = nil
                        self.newsView.hotAccountProfileName2.text = ""
                    }
                    
                    if peopleCount >= 3 {
                        self.newsView.hotAccountImageView3.kf.setImage(with: URL(string: peopleItems[2].imageUrl))
                        self.newsView.hotAccountProfileIcon3.kf.setImage(with: URL(string: peopleItems[2].profileImage))
                        self.newsView.hotAccountProfileName3.text = peopleItems[2].clokeyId
                        
                        self.newsView.hotAccountProfileIcon3.accessibilityIdentifier = peopleItems[2].clokeyId
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileIconTap))
                        self.newsView.hotAccountProfileIcon3.isUserInteractionEnabled = true
                        self.newsView.hotAccountProfileIcon3.addGestureRecognizer(tapGesture)
                        
                    } else {
                        self.newsView.hotAccountImageView3.image = nil
                        self.newsView.hotAccountProfileIcon3.image = nil
                        self.newsView.hotAccountProfileName3.text = ""
                    }
                    
                    if peopleCount >= 4 {
                        self.newsView.hotAccountImageView4.kf.setImage(with: URL(string: peopleItems[3].imageUrl))
                        self.newsView.hotAccountProfileIcon4.kf.setImage(with: URL(string: peopleItems[3].profileImage))
                        self.newsView.hotAccountProfileName4.text = peopleItems[3].clokeyId
                        
                        self.newsView.hotAccountProfileIcon4.accessibilityIdentifier = peopleItems[3].clokeyId
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileIconTap))
                        self.newsView.hotAccountProfileIcon4.isUserInteractionEnabled = true
                        self.newsView.hotAccountProfileIcon4.addGestureRecognizer(tapGesture)
                        
                    } else {
                        self.newsView.hotAccountImageView4.image = nil
                        self.newsView.hotAccountProfileIcon4.image = nil
                        self.newsView.hotAccountProfileName4.text = ""
                    }
                }
                
            case .failure(let error):
                print("Failed to fetch hot data: \(error.localizedDescription)")
            }
        }
    }
    
    
    func fetchFriendClothes() {
        let homeService = HomeService()
        
        homeService.fetchGetIssuesData { result in
            switch result {
            case .success(let responseDTO):
                DispatchQueue.main.async {
                    let closetItems = responseDTO.closet
                    
                    let isEmpty = closetItems.isEmpty
                    self.newsView.updateFriendClothesEmptyState(isEmpty: isEmpty)
                    
                    if isEmpty {
                        print("Closet 데이터가 없습니다.")
                        self.newsView.profileImageView.image = nil
                        self.newsView.usernameLabel.text = "정보 없음"
                        self.newsView.dateLabel.text = ""
                        self.newsView.friendClothesImageView1.image = nil
                        self.newsView.friendClothesImageView2.image = nil
                        self.newsView.friendClothesImageView3.image = nil
                        return
                    }
                    
                    guard let firstClosetItem = closetItems.first else {
                        print("Closet 아이템이 없습니다.")
                        return
                    }
                    
                    // ✅ 프로필 이미지 설정
                    if let firstProfileImageUrl = URL(string: firstClosetItem.profileImage) {
                        self.newsView.profileImageView.kf.setImage(with: firstProfileImageUrl)
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileIconTap))
                        self.newsView.profileImageView.isUserInteractionEnabled = true
                        self.newsView.profileImageView.addGestureRecognizer(tapGesture)
                    } else {
                        self.newsView.profileImageView.image = UIImage(named: "profile_basic")
                        print("프로필 이미지가 없습니다.")
                    }
                    
                    // ✅ 유저 이름 및 날짜 설정
                    self.newsView.usernameLabel.text = firstClosetItem.clokeyId
                    self.newsView.profileImageView.accessibilityIdentifier = firstClosetItem.clokeyId
                    self.newsView.dateLabel.text = firstClosetItem.date
                    
                    // ✅ clothesId와 images를 순서대로 가져오기
                    let itemCount = min(firstClosetItem.clothesId.count, firstClosetItem.images.count)
                    
                    let clothIds = firstClosetItem.clothesId
                    let images = firstClosetItem.images
                    
                    self.clothId1 = itemCount > 0 ? clothIds[0] : nil
                    self.clothId2 = itemCount > 1 ? clothIds[1] : nil
                    self.clothId3 = itemCount > 2 ? clothIds[2] : nil

                    self.newsView.friendClothesImageView1.kf.setImage(with: itemCount > 0 ? URL(string: images[0]) : nil)
                    self.newsView.friendClothesImageView2.kf.setImage(with: itemCount > 1 ? URL(string: images[1]) : nil)
                    self.newsView.friendClothesImageView3.kf.setImage(with: itemCount > 2 ? URL(string: images[2]) : nil)

                    if itemCount == 0 {
                        print("❌ 옷 데이터가 없습니다.")
                    }
                }
                
            case .failure(let error):
                print("Failed to fetch friend clothes data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.newsView.updateFriendClothesEmptyState(isEmpty: true)
                    self.newsView.profileImageView.image = nil
                    self.newsView.usernameLabel.text = "정보 없음"
                    self.newsView.dateLabel.text = ""
                    self.newsView.friendClothesImageView1.image = nil
                    self.newsView.friendClothesImageView2.image = nil
                    self.newsView.friendClothesImageView3.image = nil
                }
            }
        }
    }
    private let popUpView = PickPopUpView()
    private var backgroundView: UIView?// 배경 어둡게 하기 위해 선언
    
    var clothId1:Int64?
    var clothId2:Int64?
    var clothId3:Int64?
    
    private func setupActions() {
        popUpView.deleteButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        newsView.friendClothesImageView1.isUserInteractionEnabled = true
        newsView.friendClothesImageView1.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        newsView.friendClothesImageView2.isUserInteractionEnabled = true
        newsView.friendClothesImageView2.addGestureRecognizer(tapGesture2)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        newsView.friendClothesImageView3.isUserInteractionEnabled = true
        newsView.friendClothesImageView3.addGestureRecognizer(tapGesture3)
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
        
        if tappedImageView == newsView.friendClothesImageView1 {
            selectedClothId = clothId1
        } else if tappedImageView == newsView.friendClothesImageView2 {
            selectedClothId = clothId2
        } else if tappedImageView == newsView.friendClothesImageView3 {
            selectedClothId = clothId3
        }
        
        guard let clothId = selectedClothId else {
            print("❌ clothId 값이 없습니다.")
            return
        }
        
        
        showPopup(with: tappedImageView.image, clothId: clothId)
        popUpView.urlGoButton.addTarget(self, action: #selector(urlGoButtonTapped), for: .touchUpInside)
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
            make.height.equalTo(448)
        }
        
        // 팝업 애니메이션 효과
        UIView.animate(withDuration: 0.3) {
            bgView.alpha = 1
            popUpView.alpha = 1
        }
        
        // closeButton 클릭 시 팝업 닫기 기능 추가
        popUpView.deleteButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        
        let clotehsService = ClothesService()
        
        // ✅ checkPopUpClothes API 호출 및 UI 업데이트
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
                        popUpView.publicButton.setImage(UIImage(named: "public_icon"), for: .normal)
                    } else {
                        popUpView.publicButton.setImage(UIImage(named: "private_icon"), for: .normal)
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
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 1 {
                        if response.seasons[1] == "SPRING" {
                            //                                configureButton(popUpView.springButton, title: "봄")
                            popUpView.springButton.setTitleColor(.white, for: .normal)
                            popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 2 {
                        if response.seasons[2] == "SPRING" {
                            //                                configureButton(popUpView.springButton, title: "봄")
                            popUpView.springButton.setTitleColor(.white, for: .normal)
                            popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 3 {
                        if response.seasons[3] == "SPRING" {
                            //                                configureButton(popUpView.springButton, title: "봄")
                            popUpView.springButton.setTitleColor(.white, for: .normal)
                            popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    popUpView.wearCountButton.titleLabel?.text = "\(response.wearNum)"
                    popUpView.brandNameLabel.text = response.brand
                    popUpView.urlGoButton.titleLabel?.text = "\(String(describing: response.clothUrl))"
                    self.url = response.clothUrl ?? ""
                    
                    
                    // 이미지가 있으면 업데이트
                    if let imageUrl = URL(string: response.imageUrl) {
                        popUpView.imageView.kf.setImage(with: imageUrl)
                    }
                    
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
    
    
    
    
    
    
    
    
    
    
    
    
    func fetchFriendCalendar() {
        let homeService = HomeService()
        
        homeService.fetchGetIssuesData { result in
            switch result {
            case .success(let responseDTO):
                DispatchQueue.main.async {
                    let calendarItems = responseDTO.calendar
                    
                    let isEmpty = calendarItems.isEmpty
                    self.newsView.updateFriendCalendarEmptyState(isEmpty: isEmpty)
                    
                    
                    if isEmpty {
                        print("Calendar 데이터가 없습니다.")
                        return
                    }
                    
                    if let firstCalendarItem = calendarItems.first {
                        if let firstImageUrl = firstCalendarItem.imageUrl {
                            self.newsView.followingCalendarUpdateImageView1.kf.setImage(with: URL(string: firstImageUrl))
                        }
                        self.newsView.followingCalendarUpdateSubTitle.text = firstCalendarItem.date
                        self.newsView.followingCalendarProfileIcon1.kf.setImage(with: URL(string: firstCalendarItem.profileImage))
                        self.newsView.followingCalendarProfileName1.text = firstCalendarItem.clokeyId
                        
                        
                        self.newsView.followingCalendarUpdateImageView1.accessibilityIdentifier = "\(firstCalendarItem.historyId)"
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCalendarImageTap))
                        self.newsView.followingCalendarUpdateImageView1.isUserInteractionEnabled = true
                        self.newsView.followingCalendarUpdateImageView1.addGestureRecognizer(tapGesture)
                        
                        self.newsView.followingCalendarProfileIcon1.accessibilityIdentifier = firstCalendarItem.clokeyId
                        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileIconTap))
                        self.newsView.followingCalendarProfileIcon1.isUserInteractionEnabled = true
                        self.newsView.followingCalendarProfileIcon1.addGestureRecognizer(tapGesture1)
                    }
                    
                    
                    if calendarItems.count > 1, let secondImageUrl = calendarItems[1].imageUrl {
                        self.newsView.followingCalendarUpdateImageView2.kf.setImage(with: URL(string: secondImageUrl))
                        self.newsView.followingCalendarProfileIcon2.kf.setImage(with: URL(string: calendarItems[1].profileImage))
                        self.newsView.followingCalendarProfileName2.text = calendarItems[1].clokeyId
                        
                        self.newsView.followingCalendarProfileIcon2.accessibilityIdentifier = calendarItems[1].clokeyId
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileIconTap))
                        self.newsView.followingCalendarProfileIcon2.isUserInteractionEnabled = true
                        self.newsView.followingCalendarProfileIcon2.addGestureRecognizer(tapGesture)
                        
                    }
                    
                }
                
            case .failure(let error):
                print("Failed to fetch calendar data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.newsView.updateFriendCalendarEmptyState(isEmpty: true)
                }
            }
        }
    }
    
    private func setupDummyData() {
        let homeService = HomeService()
        
        homeService.fetchGetIssuesData { result in
            switch result {
            case .success(let responseDTO):
                DispatchQueue.main.async {
                    guard !responseDTO.recommend.isEmpty else {
                        print("No recommend data available.")
                        return
                    }
                    
                    self.recommandNewsSlides = responseDTO.recommend.map { recommendItem in
                        return RecommandNewsSlideModel(
                            image: recommendItem.imageUrl,
                            title: recommendItem.subTitle,
                            hashtag: recommendItem.hashtag ?? "#해시태그 없음",
                            date: recommendItem.date
                        )
                    }
                    
                    if let initialVC = self.createImageViewController(for: self.currentIndexValue()) {
                        self.pageViewController.setViewControllers([initialVC], direction: .forward, animated: false, completion: nil)
                    }
                    
                    self.setupPageControl()
                    
                    print("recommandNewsSlides 업데이트 완료: \(self.recommandNewsSlides.count)개")
                }
                
            case .failure(let error):
                print("Failed to load recommend data: \(error.localizedDescription)")
            }
        }
    }
    
    private func totalImages() -> Int {
        return recommandNewsSlides.count
    }
    
    private func image(at index: Int) -> RecommandNewsSlideModel? {
        guard index >= 0 && index < recommandNewsSlides.count else { return nil }
        return recommandNewsSlides[index]
    }
    
    private func imageIndex(of name: String) -> Int? {
        return recommandNewsSlides.firstIndex { $0.image == name }
    }
    
    private func updateCurrentIndex(to index: Int) {
        currentIndex = index
    }
    
    func currentIndexValue() -> Int {
        return currentIndex
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let initialVC = createImageViewController(for: currentIndexValue()) {
            pageViewController.setViewControllers([initialVC], direction: .forward, animated: true, completion: nil)
        }
        
        // 페이지 뷰 컨트롤러를 자식 뷰 컨트롤러로 추가
        addChild(pageViewController)
        newsView.contentView.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(newsView.recommandTitle.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(300) // 슬라이드 높이 설정
        }
    }
    
    private func setupPageControl() {
        // 페이지 컨트롤 추가 및 설정
        newsView.contentView.addSubview(pageControl)
        //        pageControl.numberOfPages = totalImages() // 이미지 개수 설정
        pageControl.numberOfPages = recommandNewsSlides.count
        pageControl.currentPage = currentIndexValue()
        
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        
        // SnapKit으로 레이아웃 설정
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(newsView.slideContainerView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func pageControlValueChanged(_ sender: UIPageControl) {
        let newIndex = sender.currentPage
        
        // 현재 표시되고 있는 뷰 컨트롤러에서 현재 인덱스를 가져옵니다.
        guard let currentVC = pageViewController.viewControllers?.first as? ImageViewController,
              let currentSlide = currentVC.slideModel,
              let currentIndex = recommandNewsSlides.firstIndex(where: { $0.title == currentSlide.title }) else {
            return
        }
        
        // 새로운 인덱스와 현재 인덱스를 비교해 전환 방향을 결정합니다.
        let direction: UIPageViewController.NavigationDirection = (newIndex >= currentIndex) ? .forward : .reverse
        
        if let newVC = createImageViewController(for: newIndex) {
            pageViewController.setViewControllers([newVC], direction: direction, animated: true, completion: nil)
            self.currentIndex = newIndex
        }
    }
    
    
    private func createImageViewController(for index: Int) -> ImageViewController? {
        guard index >= 0 && index < recommandNewsSlides.count else { return nil }
        
        let imageVC = ImageViewController()
        let slideModel = recommandNewsSlides[index]
        
        imageVC.configureView(with: slideModel)
        
        imageVC.didTapSlide = { [weak self] slide in
            guard let self = self else { return }
            let hashtag = slide.hashtag ?? ""
            let searchQuery = hashtag.hasPrefix("#") ? String(hashtag.dropFirst()) : hashtag
            
            // 예: 해시태그 탭이 기본 선택된 SearchResultViewController로 이동
            let searchResultVC = SearchResultViewController(query: searchQuery, results: [], initialTabIsHashtag: true)
            self.navigationController?.pushViewController(searchResultVC, animated: true)
        }
        
        return imageVC
    }
    
    private func setupFriendClothesBottomLabelTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFriendClothesBottomLabelTap))
        newsView.friendClothesBottomButtonLabel.isUserInteractionEnabled = true
        newsView.friendClothesBottomButtonLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleFriendClothesBottomLabelTap() {
        let detailVC = UpdateFriendClothesViewController()
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - bottomLabel에 TapGestureRecognizer 추가
    private func setupFollowingCalendarBottomLabelTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFollowingCalendarBottomLabelTap))
        newsView.followingCalendarBottomButtonLabel.isUserInteractionEnabled = true
        newsView.followingCalendarBottomButtonLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleFollowingCalendarBottomLabelTap() {
        let presentedVC = UpdateFriendCalendarViewController()
        self.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    // MARK: - 세부 기록 띄우는 Action
    @objc private func handleCalendarImageTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView,
              let historyIdString = imageView.accessibilityIdentifier,
              let historyId = Int(historyIdString) else {
            print("historyId 못찾음")
            return
        }
        
        fetchHistoryDetail(historyId: historyId)
    }
    
    private func fetchHistoryDetail(historyId: Int) {
        let historyService = HistoryService()
        
        historyService.historyDetail(historyId: historyId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("히스토리 상세 조회 성공: \(response)")
                
                let detailVC = FriendsCalendarDetailViewController()
                detailVC.setDetailData(response) //  상세 데이터 전달
                self.navigationController?.pushViewController(detailVC, animated: true)
                
            case .failure(let error):
                print("히스토리 상세 조회 실패: \(error.localizedDescription)")
            }
        }
    }
    
    
    
}

extension NewsViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? ImageViewController,
              let currentSlide = currentVC.slideModel, // `slideModel` 사용
              let currentIndex = recommandNewsSlides.firstIndex(where: { $0.title == currentSlide.title }) else {
            return nil
        }
        
        let previousIndex = currentIndex - 1
        guard previousIndex >= 0 else { return nil }
        return createImageViewController(for: previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? ImageViewController,
              let currentSlide = currentVC.slideModel, // `slideModel` 사용
              let currentIndex = recommandNewsSlides.firstIndex(where: { $0.title == currentSlide.title }) else {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        guard nextIndex < recommandNewsSlides.count else { return nil }
        return createImageViewController(for: nextIndex)
    }
}


extension NewsViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first as? ImageViewController,
              let currentSlide = currentVC.slideModel,
              let index = recommandNewsSlides.firstIndex(where: { $0.title == currentSlide.title }) else {
            return
        }
        
        self.currentIndex = index
        pageControl.currentPage = index // 페이지 컨트롤 업데이트
    }
}

