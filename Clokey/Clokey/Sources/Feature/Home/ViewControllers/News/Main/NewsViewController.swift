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

// NewsViewController는 뉴스 화면을 표시하는 ViewController로,
// 이미지 슬라이더와 추천 의상 목록을 포함합니다.
class NewsViewController: UIViewController {
    
    // 페이지 뷰 컨트롤러를 사용하여 슬라이드형 UI를 구현합니다.
    private var pageViewController: UIPageViewController!
    
    // MARK: - Properties
    private let newsView = NewsView() // 커스텀 뷰를 사용하여 화면 UI를 구성
    
    // 이미지와 현재 인덱스를 관리하는 뷰 모델 역할의 내부 프로퍼티
    private var recommandNewsSlides: [RecommandNewsSlideModel] = []
    private var currentIndex: Int = 0 // 현재 페이지의 인덱스
    
    // 더미 데이터 대신 모델을 가져옵니다.
//    private let model = NewsImageModel.dummy()
    
    // 페이지 컨트롤: 현재 슬라이드 위치를 시각적으로 표시
    private lazy var pageControl: UIPageControl = UIPageControl().then {
        $0.numberOfPages = totalImages() // 전체 이미지 개수 설정
        $0.currentPage = currentIndexValue() // 현재 페이지 설정
        $0.pageIndicatorTintColor = .lightGray // 비활성 페이지 색상
        $0.currentPageIndicatorTintColor = .black // 활성 페이지 색상
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = newsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true // 현재 컨텍스트에서 새로운 뷰 표시
        
        setupDummyData() // 더미 데이터 초기화
        setupPageViewController() // 페이지 뷰 컨트롤러 설정
        setupPageControl() // 페이지 컨트롤 설정
        
        setupFriendClothesBottomLabelTap()
        setupFollowingCalendarBottomLabelTap()
        
        fetchHotData()
        fetchFriendClothes()
        fetchFriendCalendar()
    }
    
//    private func fetchHotData() {
//        let homeService = HomeService()
//        
//        homeService.fetchGetIssuesData { result in
//            switch result {
//            case .success(let responseDTO):
//                DispatchQueue.main.async {
//                    guard responseDTO.people.count >= 4 else {
//                        print("Not enough people in response: \(responseDTO.people)")
//                        return
//                    }
//                    
//                    self.newsView.hotAccountImageView1.kf.setImage(with: URL(string: responseDTO.people[0].historyImage))
//                    self.newsView.hotAccountProfileIcon1.kf.setImage(with: URL(string: responseDTO.people[0].imageUrl))
//                    self.newsView.hotAccountProfileName1.text = responseDTO.people[0].clokeyId
//                    
//                    self.newsView.hotAccountImageView2.kf.setImage(with: URL(string: responseDTO.people[1].historyImage))
//                    self.newsView.hotAccountProfileIcon2.kf.setImage(with: URL(string: responseDTO.people[1].imageUrl))
//                    self.newsView.hotAccountProfileName2.text = responseDTO.people[1].clokeyId
//                    
//                    self.newsView.hotAccountImageView3.kf.setImage(with: URL(string: responseDTO.people[2].historyImage))
//                    self.newsView.hotAccountProfileIcon3.kf.setImage(with: URL(string: responseDTO.people[2].imageUrl))
//                    self.newsView.hotAccountProfileName3.text = responseDTO.people[2].clokeyId
//                    
//                    self.newsView.hotAccountImageView4.kf.setImage(with: URL(string: responseDTO.people[3].historyImage))
//                    self.newsView.hotAccountProfileIcon4.kf.setImage(with: URL(string: responseDTO.people[3].imageUrl))
//                    self.newsView.hotAccountProfileName4.text = responseDTO.people[3].clokeyId
//                    
//                    // ✅ 데이터 로드 후 `pageControl` 업데이트
//                    self.setupPageControl()
//                }
//                
//            case .failure(let error):
//                print("Failed to fetch hot data: \(error.localizedDescription)")
//            }
//        }
//    }
    
    private func fetchHotData() {
        let homeService = HomeService()
        
        homeService.fetchGetIssuesData { result in
            switch result {
            case .success(let responseDTO):
                DispatchQueue.main.async {
                    guard responseDTO.people.innerResult.count >= 4 else {
                        print("Not enough people in response: \(responseDTO.people.innerResult)")
                        return
                    }
                    
                    self.newsView.hotAccountImageView1.kf.setImage(with: URL(string: responseDTO.people.innerResult[0].historyImage))
                    self.newsView.hotAccountProfileIcon1.kf.setImage(with: URL(string: responseDTO.people.innerResult[0].imageUrl))
                    self.newsView.hotAccountProfileName1.text = responseDTO.people.innerResult[0].clokeyId
                    
                    self.newsView.hotAccountImageView2.kf.setImage(with: URL(string: responseDTO.people.innerResult[1].historyImage))
                    self.newsView.hotAccountProfileIcon2.kf.setImage(with: URL(string: responseDTO.people.innerResult[1].imageUrl))
                    self.newsView.hotAccountProfileName2.text = responseDTO.people.innerResult[1].clokeyId
                    
                    self.newsView.hotAccountImageView3.kf.setImage(with: URL(string: responseDTO.people.innerResult[2].historyImage))
                    self.newsView.hotAccountProfileIcon3.kf.setImage(with: URL(string: responseDTO.people.innerResult[2].imageUrl))
                    self.newsView.hotAccountProfileName3.text = responseDTO.people.innerResult[2].clokeyId
                    
                    self.newsView.hotAccountImageView4.kf.setImage(with: URL(string: responseDTO.people.innerResult[3].historyImage))
                    self.newsView.hotAccountProfileIcon4.kf.setImage(with: URL(string: responseDTO.people.innerResult[3].imageUrl))
                    self.newsView.hotAccountProfileName4.text = responseDTO.people.innerResult[3].clokeyId
                    
                    // ✅ 데이터 로드 후 `pageControl` 업데이트
                    self.setupPageControl()
                }
                
            case .failure(let error):
                print("Failed to fetch hot data: \(error.localizedDescription)")
            }
        }
    }
    
    
//    func fetchFriendClothes() {
//        let homeService = HomeService()
//        
//        homeService.fetchGetIssuesData { result in
//            switch result {
//            case .success(let responseDTO):
//                DispatchQueue.main.async {
//                    let closetItems = responseDTO.closet
//                    
//                    let isEmpty = closetItems.isEmpty
//                    self.newsView.updateFriendClothesEmptyState(isEmpty: isEmpty)
//                    
//                    if let firstProfileImageUrl = closetItems.first?.profileImage {
//                        self.newsView.profileImageView.kf.setImage(with: URL(string: firstProfileImageUrl))
//                    }
//                    if let firstClosetItem = closetItems.first {
//                        self.newsView.usernameLabel.text = firstClosetItem.clokeyId
//                        self.newsView.dateLabel.text = self.formatDate(firstClosetItem.date)
//                    }
//                    
//                    if isEmpty {
//                        print("🚨 Closet 데이터가 없습니다.")
//                        return
//                    }
//                    
//                    // ✅ 최소 3개의 데이터가 있는지 체크 후 이미지 설정
//                    if closetItems.count >= 3 {
//                        self.newsView.friendClothesImageView1.kf.setImage(with: URL(string: closetItems[0].images.first ?? ""))
//                        self.newsView.friendClothesImageView2.kf.setImage(with: URL(string: closetItems[1].images.first ?? ""))
//                        self.newsView.friendClothesImageView3.kf.setImage(with: URL(string: closetItems[2].images.first ?? ""))
//                    } else {
//                        print("Closet 데이터가 3개 미만입니다. \(closetItems.count)개만 존재.")
//                    }
//                }
//                
//            case .failure(let error):
//                print("Failed to fetch friend clothes data: \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    self.newsView.updateFriendClothesEmptyState(isEmpty: true)
//                }
//            }
//        }
//    }
    
    func fetchFriendClothes() {
        let homeService = HomeService()
        
        homeService.fetchGetIssuesData { result in
            switch result {
            case .success(let responseDTO):
                DispatchQueue.main.async {
                    let closetItems = responseDTO.closet.innerResult // ✅ 변경된 구조 반영
                    
                    let isEmpty = closetItems.isEmpty
                    self.newsView.updateFriendClothesEmptyState(isEmpty: isEmpty)
                    
                    if let firstProfileImageUrl = closetItems.first?.profileImage {
                        self.newsView.profileImageView.kf.setImage(with: URL(string: firstProfileImageUrl))
                    }
                    if let firstClosetItem = closetItems.first {
                        self.newsView.usernameLabel.text = firstClosetItem.clokeyId
                        self.newsView.dateLabel.text = self.formatDate(firstClosetItem.date)
                    }
                    
                    if isEmpty {
                        print("🚨 Closet 데이터가 없습니다.")
                        return
                    }
                    
                    // ✅ 최소 3개의 데이터가 있는지 체크 후 이미지 설정
                    if closetItems.count >= 3 {
                        self.newsView.friendClothesImageView1.kf.setImage(with: URL(string: closetItems[0].images.first ?? ""))
                        self.newsView.friendClothesImageView2.kf.setImage(with: URL(string: closetItems[1].images.first ?? ""))
                        self.newsView.friendClothesImageView3.kf.setImage(with: URL(string: closetItems[2].images.first ?? ""))
                    } else {
                        print("Closet 데이터가 3개 미만입니다. \(closetItems.count)개만 존재.")
                    }
                }
                
            case .failure(let error):
                print("Failed to fetch friend clothes data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.newsView.updateFriendClothesEmptyState(isEmpty: true)
                }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // 기존 API 형식
        inputFormatter.locale = Locale(identifier: "ko_KR") // 한국 시간 설정
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd" // 원하는 형식
            return outputFormatter.string(from: date)
        }
        
        return dateString // 변환 실패 시 원본 반환
    }
    
//    func fetchFriendCalendar() {
//        let homeService = HomeService()
//        
//        homeService.fetchGetIssuesData { result in
//            switch result {
//            case .success(let responseDTO):
//                DispatchQueue.main.async {
//                    let calendarItems = responseDTO.calendar
//                    
//                    // ✅ Calendar 데이터가 있는지 확인 후 EmptyState 설정
//                    let isEmpty = calendarItems.isEmpty
//                    self.newsView.updateFriendCalendarEmptyState(isEmpty: isEmpty)
//                    
//                    
//                    if isEmpty {
//                        print("🚨 Calendar 데이터가 없습니다.")
//                        return
//                    }
//
//                    if let firstCalendarItem = calendarItems.first {
//                        if let firstImageUrl = firstCalendarItem.events.first?.imageUrl {
//                            self.newsView.followingCalendarUpdateImageView1.kf.setImage(with: URL(string: firstImageUrl))
//                        }
//                        self.newsView.followingCalendarUpdateSubTitle.text = self.formatDate(firstCalendarItem.date)
//                        
//                        self.newsView.followingCalendarProfileIcon1.kf.setImage(with: URL(string: firstCalendarItem.profileImage))
//                        self.newsView.followingCalendarProfileName1.text = firstCalendarItem.clokeyId
//                    }
//                    
//                    
//                    if calendarItems.count > 1, let secondImageUrl = calendarItems[1].events.first?.imageUrl {
//                        self.newsView.followingCalendarUpdateImageView2.kf.setImage(with: URL(string: secondImageUrl))
//                        self.newsView.followingCalendarProfileIcon2.kf.setImage(with: URL(string: calendarItems[1].profileImage))
//                        self.newsView.followingCalendarProfileName2.text = calendarItems[1].clokeyId
//                    }
//                    
//                }
//                
//            case .failure(let error):
//                print("Failed to fetch calendar data: \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    self.newsView.updateFriendCalendarEmptyState(isEmpty: true)
//                }
//            }
//        }
//    }
    
    func fetchFriendCalendar() {
        let homeService = HomeService()
        
        homeService.fetchGetIssuesData { result in
            switch result {
            case .success(let responseDTO):
                DispatchQueue.main.async {
                    let calendarItems = responseDTO.calendar.innerResult // ✅ 변경된 구조 반영
                    
                    // ✅ Calendar 데이터가 있는지 확인 후 EmptyState 설정
                    let isEmpty = calendarItems.isEmpty
                    self.newsView.updateFriendCalendarEmptyState(isEmpty: isEmpty)
                    
                    if isEmpty {
                        print("🚨 Calendar 데이터가 없습니다.")
                        return
                    }

                    if let firstCalendarItem = calendarItems.first {
                        if let firstImageUrl = firstCalendarItem.events.first?.imageUrl {
                            self.newsView.followingCalendarUpdateImageView1.kf.setImage(with: URL(string: firstImageUrl))
                        }
                        self.newsView.followingCalendarUpdateSubTitle.text = self.formatDate(firstCalendarItem.date)
                        
                        self.newsView.followingCalendarProfileIcon1.kf.setImage(with: URL(string: firstCalendarItem.profileImage))
                        self.newsView.followingCalendarProfileName1.text = firstCalendarItem.clokeyId
                    }
                    
                    if calendarItems.count > 1, let secondImageUrl = calendarItems[1].events.first?.imageUrl {
                        self.newsView.followingCalendarUpdateImageView2.kf.setImage(with: URL(string: secondImageUrl))
                        self.newsView.followingCalendarProfileIcon2.kf.setImage(with: URL(string: calendarItems[1].profileImage))
                        self.newsView.followingCalendarProfileName2.text = calendarItems[1].clokeyId
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
    
    
//    private func setupDummyData() {
//        recommandNewsSlides = RecommandNewsSlideModel.slideDummyData()
//        
//    }
    
//    private func setupDummyData() {
//        let homeService = HomeService()
//
//        homeService.fetchGetIssuesData { result in
//            switch result {
//            case .success(let responseDTO):
//                DispatchQueue.main.async {
//                    // ✅ recommend 배열이 비어있는지 확인
//                    guard !responseDTO.recommend.isEmpty else {
//                        print("🚨 No recommend data available.")
//                        return
//                    }
//
//                    // ✅ 서버에서 받아온 데이터를 recommandNewsSlides 배열에 저장
//                    self.recommandNewsSlides = responseDTO.recommend.map { recommendItem in
//                        return RecommandNewsSlideModel(
//                            image: recommendItem.imageUrl,
//                            title: recommendItem.subTitle ?? "제목 없음",
//                            hashtag: recommendItem.hashtag ?? "#해시태그 없음",
//                            date: recommendItem.date
//                        )
//                    }
//
//                    // ✅ 첫 번째 슬라이드를 설정하여 pageViewController에 반영
//                    if let initialVC = self.createImageViewController(for: self.currentIndexValue()) {
//                        self.pageViewController.setViewControllers([initialVC], direction: .forward, animated: false, completion: nil)
//                    }
//
//                    // ✅ 페이지 컨트롤 UI 업데이트
//                    self.setupPageControl()
//
//                    print("✅ recommandNewsSlides 업데이트 완료: \(self.recommandNewsSlides.count)개")
//                }
//                
//            case .failure(let error):
//                print("❌ Failed to load recommend data: \(error.localizedDescription)")
//            }
//        }
//    }
    
    private func setupDummyData() {
        let homeService = HomeService()

        homeService.fetchGetIssuesData { result in
            switch result {
            case .success(let responseDTO):
                DispatchQueue.main.async {
                    // ✅ recommend.innerResult 배열이 비어있는지 확인
                    guard !responseDTO.recommend.innerResult.isEmpty else {
                        print("🚨 No recommend data available.")
                        return
                    }

                    // ✅ 서버에서 받아온 데이터를 recommandNewsSlides 배열에 저장
                    self.recommandNewsSlides = responseDTO.recommend.innerResult.map { recommendItem in
                        return RecommandNewsSlideModel(
                            image: recommendItem.imageUrl,
                            title: recommendItem.subTitle,
                            hashtag: recommendItem.hashtag,
                            date: recommendItem.date
                        )
                    }

                    // ✅ 첫 번째 슬라이드를 설정하여 pageViewController에 반영
                    if let initialVC = self.createImageViewController(for: self.currentIndexValue()) {
                        self.pageViewController.setViewControllers([initialVC], direction: .forward, animated: false, completion: nil)
                    }

                    // ✅ 페이지 컨트롤 UI 업데이트
                    self.setupPageControl()

                    print("✅ recommandNewsSlides 업데이트 완료: \(self.recommandNewsSlides.count)개")
                }
                
            case .failure(let error):
                print("❌ Failed to load recommend data: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helper Methods
    // 전체 이미지 개수를 반환합니다.
    private func totalImages() -> Int {
        return recommandNewsSlides.count
    }
    
    // 주어진 인덱스에 해당하는 슬라이드 데이터를 반환합니다.
    private func image(at index: Int) -> RecommandNewsSlideModel? {
        guard index >= 0 && index < recommandNewsSlides.count else { return nil }
        return recommandNewsSlides[index]
    }
    
    // 주어진 이름의 슬라이드 인덱스를 반환합니다.
    private func imageIndex(of name: String) -> Int? {
        return recommandNewsSlides.firstIndex { $0.image == name }
    }
    
    // 현재 인덱스를 업데이트합니다.
    private func updateCurrentIndex(to index: Int) {
        currentIndex = index
    }
    
    // 현재 인덱스를 반환합니다.
    func currentIndexValue() -> Int {
        return currentIndex
    }
    
    // MARK: - Page View Controller Setup
    private func setupPageViewController() {
        // 페이지 뷰 컨트롤러 초기화 및 데이터 소스와 델리게이트 설정
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // 초기 슬라이드 설정
        if let initialVC = createImageViewController(for: currentIndexValue()) {
            pageViewController.setViewControllers([initialVC], direction: .forward, animated: true, completion: nil)
        }
        
        // 페이지 뷰 컨트롤러를 자식 뷰 컨트롤러로 추가
        addChild(pageViewController)
        newsView.contentView.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        // SnapKit으로 레이아웃 설정
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
        
        imageVC.configureView(with: slideModel) // ✅ 정확한 데이터 전달
        imageVC.slideModel = slideModel // ✅ 직접 slideModel 저장 (추가)
        
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
              let currentSlide = currentVC.slideModel, // `slideModel` 사용
              let index = recommandNewsSlides.firstIndex(where: { $0.title == currentSlide.title }) else {
            return
        }
        
        self.currentIndex = index
        pageControl.currentPage = index // 페이지 컨트롤 업데이트
    }
}



