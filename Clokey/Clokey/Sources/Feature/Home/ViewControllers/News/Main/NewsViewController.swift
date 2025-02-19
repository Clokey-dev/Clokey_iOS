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
                        let person = peopleItems[0]
                        
                        // 이미지뷰: 게시물 상세 이동
                        self.newsView.hotAccountImageView1.kf.setImage(with: URL(string: person.imageUrl))
                        self.newsView.hotAccountImageView1.accessibilityIdentifier = "\(person.historyId)"  // 게시물 상세에 필요한 id 저장
                        self.newsView.hotAccountImageView1.isUserInteractionEnabled = true
                        let imageTapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.handleHotAccountImageTap))
                        self.newsView.hotAccountImageView1.addGestureRecognizer(imageTapGesture1)
                        
                        // 프로필 아이콘: 프로필 이동
                        self.newsView.hotAccountProfileIcon1.kf.setImage(with: URL(string: person.profileImage))
                        self.newsView.hotAccountProfileIcon1.accessibilityIdentifier = person.clokeyId // clokeyID 저장
                        self.newsView.hotAccountProfileIcon1.isUserInteractionEnabled = true
                        let iconTapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileTap))
                        self.newsView.hotAccountProfileIcon1.addGestureRecognizer(iconTapGesture1)
                        
                        // 프로필 이름: 프로필 이동
                        self.newsView.hotAccountProfileName1.text = person.clokeyId
                        self.newsView.hotAccountProfileName1.accessibilityIdentifier = person.clokeyId // clokeyID 저장
                        self.newsView.hotAccountProfileName1.isUserInteractionEnabled = true
                        let nameTapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileTap))
                        self.newsView.hotAccountProfileName1.addGestureRecognizer(nameTapGesture1)
                    } else {
                        self.newsView.hotAccountImageView1.image = nil
                        self.newsView.hotAccountProfileIcon1.image = nil
                        self.newsView.hotAccountProfileName1.text = ""
                    }
                    if peopleCount >= 2 {
                        let person = peopleItems[1]
                        self.newsView.hotAccountImageView2.kf.setImage(with: URL(string: person.imageUrl))
                        self.newsView.hotAccountImageView2.accessibilityIdentifier = "\(person.historyId)"
                        self.newsView.hotAccountImageView2.isUserInteractionEnabled = true
                        let imageTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleHotAccountImageTap))
                        self.newsView.hotAccountImageView2.addGestureRecognizer(imageTapGesture2)
                        
                        self.newsView.hotAccountProfileIcon2.kf.setImage(with: URL(string: person.profileImage))
                        self.newsView.hotAccountProfileIcon2.accessibilityIdentifier = person.clokeyId
                        self.newsView.hotAccountProfileIcon2.isUserInteractionEnabled = true
                        let iconTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileTap))
                        self.newsView.hotAccountProfileIcon2.addGestureRecognizer(iconTapGesture2)
                        
                        self.newsView.hotAccountProfileName2.text = person.clokeyId
                        self.newsView.hotAccountProfileName2.accessibilityIdentifier = person.clokeyId
                        self.newsView.hotAccountProfileName2.isUserInteractionEnabled = true
                        let nameTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileTap))
                        self.newsView.hotAccountProfileName2.addGestureRecognizer(nameTapGesture2)
                    } else {
                        self.newsView.hotAccountImageView2.image = nil
                        self.newsView.hotAccountProfileIcon2.image = nil
                        self.newsView.hotAccountProfileName2.text = ""
                    }
                    
                    if peopleCount >= 3 {
                        let person = peopleItems[2]
                        self.newsView.hotAccountImageView2.kf.setImage(with: URL(string: person.imageUrl))
                        self.newsView.hotAccountImageView2.accessibilityIdentifier = "\(person.historyId)"
                        self.newsView.hotAccountImageView2.isUserInteractionEnabled = true
                        let imageTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleHotAccountImageTap))
                        self.newsView.hotAccountImageView2.addGestureRecognizer(imageTapGesture2)
                        
                        self.newsView.hotAccountProfileIcon2.kf.setImage(with: URL(string: person.profileImage))
                        self.newsView.hotAccountProfileIcon2.accessibilityIdentifier = person.clokeyId
                        self.newsView.hotAccountProfileIcon2.isUserInteractionEnabled = true
                        let iconTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileTap))
                        self.newsView.hotAccountProfileIcon2.addGestureRecognizer(iconTapGesture2)
                        
                        self.newsView.hotAccountProfileName2.text = person.clokeyId
                        self.newsView.hotAccountProfileName2.accessibilityIdentifier = person.clokeyId
                        self.newsView.hotAccountProfileName2.isUserInteractionEnabled = true
                        let nameTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileTap))
                        self.newsView.hotAccountProfileName2.addGestureRecognizer(nameTapGesture2)
                    } else {
                        self.newsView.hotAccountImageView2.image = nil
                        self.newsView.hotAccountProfileIcon2.image = nil
                        self.newsView.hotAccountProfileName2.text = ""
                    }
                    
                    
                    if peopleCount >= 4 {
                        let person = peopleItems[3]
                        self.newsView.hotAccountImageView2.kf.setImage(with: URL(string: person.imageUrl))
                        self.newsView.hotAccountImageView2.accessibilityIdentifier = "\(person.historyId)"
                        self.newsView.hotAccountImageView2.isUserInteractionEnabled = true
                        let imageTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleHotAccountImageTap))
                        self.newsView.hotAccountImageView2.addGestureRecognizer(imageTapGesture2)
                        
                        self.newsView.hotAccountProfileIcon2.kf.setImage(with: URL(string: person.profileImage))
                        self.newsView.hotAccountProfileIcon2.accessibilityIdentifier = person.clokeyId
                        self.newsView.hotAccountProfileIcon2.isUserInteractionEnabled = true
                        let iconTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileTap))
                        self.newsView.hotAccountProfileIcon2.addGestureRecognizer(iconTapGesture2)
                        
                        self.newsView.hotAccountProfileName2.text = person.clokeyId
                        self.newsView.hotAccountProfileName2.accessibilityIdentifier = person.clokeyId
                        self.newsView.hotAccountProfileName2.isUserInteractionEnabled = true
                        let nameTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileTap))
                        self.newsView.hotAccountProfileName2.addGestureRecognizer(nameTapGesture2)
                    } else {
                        self.newsView.hotAccountImageView2.image = nil
                        self.newsView.hotAccountProfileIcon2.image = nil
                        self.newsView.hotAccountProfileName2.text = ""
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
                    
                    if let firstProfileImageUrl = closetItems.first?.profileImage, let url = URL(string: firstProfileImageUrl) {
                        self.newsView.profileImageView.kf.setImage(with: url)
                        
                        
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileIconTap))
                        self.newsView.profileImageView.isUserInteractionEnabled = true
                        self.newsView.profileImageView.addGestureRecognizer(tapGesture)
                        
                    } else {
                        self.newsView.profileImageView.image = UIImage(named: "profile_basic")
                        print("프로필 이미지가 없습니다.")
                    }
                    
                    if let firstClosetItem = closetItems.first {
                        self.newsView.usernameLabel.text = firstClosetItem.clokeyId
                        
                        self.newsView.profileImageView.accessibilityIdentifier = firstClosetItem.clokeyId
                        
                        self.newsView.dateLabel.text = firstClosetItem.date
                    } else {
                        self.newsView.usernameLabel.text = "정보 없음"
                        self.newsView.dateLabel.text = ""
                        print("Closet 아이템이 없습니다.")
                    }
                    
                    if closetItems.count >= 1, let firstImageUrl = closetItems[0].images.first, let url1 = URL(string: firstImageUrl) {
                        self.newsView.friendClothesImageView1.kf.setImage(with: url1)
                    } else {
                        self.newsView.friendClothesImageView1.image = nil
                        print("첫 번째 옷 이미지가 없습니다.")
                    }
                    
                    if closetItems.count >= 2, let secondImageUrl = closetItems[1].images.first, let url2 = URL(string: secondImageUrl) {
                        self.newsView.friendClothesImageView2.kf.setImage(with: url2)
                    } else {
                        self.newsView.friendClothesImageView2.image = nil
                        print("두 번째 옷 이미지가 없습니다.")
                    }
                    
                    if closetItems.count >= 3, let thirdImageUrl = closetItems[2].images.first, let url3 = URL(string: thirdImageUrl) {
                        self.newsView.friendClothesImageView3.kf.setImage(with: url3)
                    } else {
                        self.newsView.friendClothesImageView3.image = nil
                        print("세 번째 옷 이미지가 없습니다.")
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
        
        // SnapKit으로 레이아웃 설정
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(newsView.slideContainerView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
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
    
    // 게시물 상세 페이지로 이동하는 액션 (예: historyId를 이용)
    @objc private func handleHotAccountImageTap(_ sender: UITapGestureRecognizer) {
        // 이미지뷰의 accessibilityIdentifier에 게시물의 historyId가 저장되어 있다고 가정합니다.
        guard let imageView = sender.view as? UIImageView,
              let historyIdString = imageView.accessibilityIdentifier,
              let historyId = Int(historyIdString) else {
            print("게시물 historyId를 찾을 수 없음")
            return
        }
        // 게시물 상세 페이지로 이동 (예: FriendsCalendarDetailViewController 사용)
        fetchHistoryDetail(historyId: historyId)
    }

    // 프로필 페이지로 이동하는 액션 (clokeyID를 이용)
    @objc private func handleProfileTap(_ sender: UITapGestureRecognizer) {
        // sender.view의 accessibilityIdentifier에 clokeyID가 저장되어 있다고 가정합니다.
        guard let view = sender.view,
              let clokeyID = view.accessibilityIdentifier else {
            print("clokeyID를 찾을 수 없음")
            return
        }
        let followProfileVC = FollowProfileViewController()
        // FollowProfileViewController에서는 clokeyID를 followId (또는 clokey_Id)로 사용합니다.
        followProfileVC.followId = clokeyID
        self.navigationController?.pushViewController(followProfileVC, animated: true)
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

