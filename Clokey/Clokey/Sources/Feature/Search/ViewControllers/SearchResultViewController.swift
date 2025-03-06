//
//  SearchResultViewController.swift
//  Clokey
//
//  Created by 소민준 on 2/5/25.
//

//
//  SearchResultViewController.swift
//  Clokey
//
//  Created by 소민준 on 2/5/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

class SearchResultViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    private let searchView = SearchResultView()
    private let searchManager = SearchManager()
    
    private var users: [UserModel]
    private var query: String
    
    var dummyImages: [String] = []
    var dummyHistoryIDs: [Int] = []
    private var filteredUsers: [UserModel] = []
    private var searchHistory: [String] = []
    private var initialTabIsHashtag: Bool = false
    
    private var isFetchingData = false
    // 서버 연결을 위한 변수들
    private var currentPage = 1
    private let pageSize = 20
    private var hasMorePages = true
    
    
    override func loadView() {
        view = searchView
    }
    init(query: String, results: [UserModel],  initialTabIsHashtag: Bool = false) {
        self.query = query
        self.users = results
        self.initialTabIsHashtag = initialTabIsHashtag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        searchView.accountsCollectionView.reloadData()
        //  네비게이션 바 스타일 설정
        
        setupRefreshControl()
        
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        searchView.hashtagsCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        searchView.accountsCollectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.identifier)
        searchView.searchField.delegate = self
        searchView.accountsCollectionView.delegate = self
        searchView.accountsCollectionView.dataSource = self
        searchView.hashtagsCollectionView.delegate = self
        searchView.hashtagsCollectionView.dataSource = self
        searchView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        searchView.accountButton.addTarget(self, action: #selector(tabSelected(_:)), for: .touchUpInside)
        searchView.hashtagButton.addTarget(self, action: #selector(tabSelected(_:)), for: .touchUpInside)
        searchView.searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        searchView.accountsCollectionView.isScrollEnabled = true
        searchView.hashtagsCollectionView.isScrollEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        loadSearchHistory()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleTabSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleTabSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        searchView.searchField.text = query
        filterUsers(with: query)
        addSearchHistory(query)
        /* DispatchQueue.main.async {
         self.updateIndicatorPosition(selectedButton: self.searchView.accountButton)
         }*/
        if initialTabIsHashtag {
            // 해시태그 탭 선택 UI 적용
            searchView.hashtagButton.setTitleColor(UIColor(named: "pointOrange800"), for: .normal)
            searchView.accountButton.setTitleColor(.lightGray, for: .normal)
            searchView.accountsCollectionView.isHidden = true
            searchView.hashtagsCollectionView.isHidden = false
            
            DispatchQueue.main.async {
                self.updateIndicatorPosition(selectedButton: self.searchView.hashtagButton)
            }
            // 해시태그 API 호출
            loadHistoryData(query: query, isNextPage: false)
        } else {
            // 계정 탭 기본 선택 (기존 로직)
            filterUsers(with: query)
            DispatchQueue.main.async {
                self.updateIndicatorPosition(selectedButton: self.searchView.accountButton)
            }
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationController?.setNavigationBarHidden(true, animated: false)
        searchView.hashtagsCollectionView.reloadData()
        searchView.accountsCollectionView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.view.backgroundColor = .white
        searchHistory = searchManager.fetchRecentSearches() //  검색 기록 강제 업데이트
        searchView.accountsCollectionView.reloadData()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc private func tabSelected(_ sender: UIButton) {
        guard !query.isEmpty else { return }
        let isAccountTab = sender == searchView.accountButton
        
        //  UI 업데이트
        searchView.accountButton.setTitleColor(isAccountTab ? UIColor(named: "pointOrange800") : .lightGray, for: .normal)
        searchView.hashtagButton.setTitleColor(isAccountTab ? .lightGray : UIColor(named: "pointOrange800"), for: .normal)
        
        searchView.accountsCollectionView.isHidden = !isAccountTab
        searchView.hashtagsCollectionView.isHidden = isAccountTab
        
        updateIndicatorPosition(selectedButton: sender)
        updateEmptyLabel()
        
        
        //  탭 변경 시 API 호출
        currentPage = 1
        hasMorePages = true
        
        if isAccountTab {
            loadMemberData(query: query, isNextPage: false)
        } else {
            loadHistoryData(query: query, isNextPage: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        // 컬렉션뷰가 스크롤 가능한 경우에만 무한 스크롤 API 호출
        if contentHeight > frameHeight,
           offsetY > contentHeight - frameHeight - 100,
           let query = searchView.searchField.text, !query.isEmpty {
            
            if scrollView == searchView.accountsCollectionView {
                guard !isFetchingData else { return }
                loadMemberData(query: query, isNextPage: true)
            } else if scrollView == searchView.hashtagsCollectionView {
                guard !isFetchingData else { return }
                loadHistoryData(query: query, isNextPage: true)
            }
        }
    }
    private func addSearchHistory(_ query: String) {
        var searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
        searchHistory.removeAll { $0 == query }
        searchHistory.insert(query, at: 0)
        if searchHistory.count > 10 {
            searchHistory = Array(searchHistory.prefix(10))
        }
        UserDefaults.standard.setValue(searchHistory, forKey: "searchHistory")
        loadSearchHistory()
    }
    //인디케이터 이동애니메이션
    // 인디케이터 이동 애니메이션
    private func updateIndicatorPosition(selectedButton: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.searchView.indicatorView.transform = CGAffineTransform(translationX: selectedButton.center.x - self.searchView.indicatorView.center.x, y: 0)
        })
    }
    
    
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
        
    }
    
    private func filterUsers(with query: String) {
        guard !query.isEmpty else {
            filteredUsers = users
            DispatchQueue.main.async {
                self.searchView.emptyLabel.isHidden = true
                self.searchView.accountsCollectionView.reloadData()
            }
            return
        }
        
        filteredUsers = users.filter { user in
            let lowercasedQuery = query.lowercased()
            
            let clokeyId = user.clokeyId.lowercased()  // nil이면 빈 문자열 처리
            let nickname = user.nickname.lowercased()  // nil이면 빈 문자열 처리
            
            return clokeyId.contains(lowercasedQuery) || nickname.contains(lowercasedQuery)
        }
        DispatchQueue.main.async {
            let hasResults = !self.filteredUsers.isEmpty
            self.searchView.emptyLabel.isHidden = hasResults
            self.searchView.accountsCollectionView.reloadData()
        }
    }
    
    private func saveSearchQuery(_ query: String) {
        var searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
        
        
        //  중복 제거 후 맨 앞에 추가
        searchHistory.removeAll { $0 == query }
        searchHistory.insert(query, at: 0)
        
        //  최대 10개까지만 저장
        if searchHistory.count > 10 {
            searchHistory = Array(searchHistory.prefix(10))
        }
        
        UserDefaults.standard.setValue(searchHistory, forKey: "searchHistory")
        
        
        
        //  검색 기록 다시 불러오고 UI 업데이트
        loadSearchHistory()
    }
    private func loadMemberData(query: String, isNextPage: Bool = false) {
        guard hasMorePages else { return }
        
        let page = isNextPage ? currentPage + 1 : 1
        
        
        SearchService().searchMember(by :"id-and-nickname", keyword: query, page: 1, size: 20) { [weak self] result in
            switch result {
            case .success(let response):
                let users = response.profilePreviews.map { member in
                    UserModel(
                        
                        clokeyId: member.clokeyId ?? "없는 사용자",
                        nickname: member.nickname ?? "없는 닉네임",
                        profileImage: member.profileImage ?? "없는 프로필"
                    )
                }
                
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    self.users = users
                    self.filteredUsers = users
                    self.updateEmptyLabel() //  검색 결과가 있으면 숨기기
                    self.searchView.accountsCollectionView.reloadData()
                }
                
                
            case .failure(let error):
                print("❌ 검색 실패: \(error.localizedDescription)")
            }
        }
    }
    private func updateEmptyLabel() {
        let isAccountTab = !searchView.accountsCollectionView.isHidden
        
        if isAccountTab {
            searchView.emptyLabel.isHidden = !filteredUsers.isEmpty
        } else {
            searchView.emptyLabel.isHidden = !dummyImages.isEmpty
        }
    }
    private func loadHistoryData(query: String, isNextPage: Bool = false) {
        // 중복 요청 방지
        guard !isFetchingData, hasMorePages else { return }
        
        isFetchingData = true  // API 요청 중 상태 설정
        let page = isNextPage ? currentPage + 1 : 1
        if !isNextPage {
                dummyImages.removeAll()
                dummyHistoryIDs.removeAll()
            }

        SearchService().searchHistory(by: "hashtag-and-category", keyword: query, page: page, size: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isFetchingData = false  // API 요청 완료 상태로 변경

                switch result {
                case .success(let response):
                    let newImages = response.historyPreviews.map { $0.imageUrl }
                    let newHistoryIDs: [Int] = response.historyPreviews.map { Int($0.id) }

                    if isNextPage {
                        self.dummyImages.append(contentsOf: newImages)
                        self.dummyHistoryIDs.append(contentsOf: newHistoryIDs)
                        self.currentPage = page
                    } else {
                        self.dummyImages = newImages
                        self.dummyHistoryIDs = newHistoryIDs
                        self.currentPage = 1
                    }

                    self.searchView.hashtagsCollectionView.reloadData()
                    self.updateEmptyLabel()

                case .failure(let error):
                    print("❌ 해시태그 검색 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let query = textField.text, !query.isEmpty else {
            print(" 현재 검색어 없음, 기존 데이터 유지")
            
            //  해시태그 탭이 선택된 경우, 기존 데이터를 유지하도록 수정
            if !searchView.hashtagsCollectionView.isHidden {
                return
            }
            
            //  계정 탭이 선택된 경우, 필터 초기화
            filteredUsers = users
            DispatchQueue.main.async {
                self.searchView.emptyLabel.isHidden = true
                self.searchView.accountsCollectionView.reloadData()
            }
            return
        }
        
        
        
        //  계정 탭이 선택된 경우, 필터링 수행
        if !searchView.accountsCollectionView.isHidden {
            filterUsers(with: query)
        }
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func handleCalendarImageTap(_ sender: UITapGestureRecognizer) {
        // sender.view가 UIImageView임을 확인하고, accessibilityIdentifier에 저장된 히스토리 아이디를 가져옴
        guard let imageView = sender.view as? UIImageView,
              let historyIdString = imageView.accessibilityIdentifier,
              let historyId = Int(historyIdString) else {
            
            return
        }
        
        // 히스토리 아이디를 이용하여 상세 정보를 조회
        fetchHistoryDetail(historyId: historyId)
    }
    @objc private func handleTabSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            // 왼쪽 스와이프 → 계정 탭에서 해시태그 탭으로 전환 (계정 탭이 보이면)
            if !searchView.accountsCollectionView.isHidden {
                tabSelected(searchView.hashtagButton)
            }
        } else if gesture.direction == .right {
            // 오른쪽 스와이프 → 해시태그 탭에서 계정 탭으로 전환 (해시태그 탭이 보이면)
            if !searchView.hashtagsCollectionView.isHidden {
                tabSelected(searchView.accountButton)
            }
        }
    }
    private func setupRefreshControl() {
        let refreshControlAccount = UIRefreshControl()
        refreshControlAccount.addTarget(self, action: #selector(refreshAccounts), for: .valueChanged)
        searchView.accountsCollectionView.refreshControl = refreshControlAccount
        
        let refreshControlHashtag = UIRefreshControl()
        refreshControlHashtag.addTarget(self, action: #selector(refreshHashtags), for: .valueChanged)
        searchView.hashtagsCollectionView.refreshControl = refreshControlHashtag
    }
    @objc private func refreshAccounts() {
       
        guard !query.isEmpty else {
            searchView.accountsCollectionView.refreshControl?.endRefreshing()
            return
        }

        loadMemberData(query: query, isNextPage: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.searchView.accountsCollectionView.refreshControl?.endRefreshing()
        }
    }

    //  해시태그 목록 새로고침
    @objc private func refreshHashtags() {
        

        // 중복 요청 방지
        guard !isFetchingData else {
            searchView.hashtagsCollectionView.refreshControl?.endRefreshing()
            return
        }
        
        guard !query.isEmpty else {
            searchView.hashtagsCollectionView.refreshControl?.endRefreshing()
            return
        }

        // 기존 데이터 초기화
        dummyImages.removeAll()
        dummyHistoryIDs.removeAll()
        searchView.hashtagsCollectionView.reloadData()
        
        // isFetchingData 플래그를 loadHistoryData 내부에서 관리하도록 호출
        loadHistoryData(query: query, isNextPage: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.searchView.hashtagsCollectionView.refreshControl?.endRefreshing()
            self.updateEmptyLabel()
        }
    
    
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        // API가 진행 중이면 터치 이벤트 무시
        if isFetchingData {
            print("⚠️ API 요청 중이므로 터치 이벤트 무시")
            return
        }
    }
    
}

extension SearchResultViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text, !query.isEmpty else { return false }
        
        dummyImages.removeAll()
           dummyHistoryIDs.removeAll()
        
        //  검색어 저장 추가
        searchManager.addSearchKeyword(query)
        
        //  현재 선택된 탭 확인
        let isAccountTabSelected = !searchView.accountsCollectionView.isHidden
        
        if isAccountTabSelected {
            //  계정 검색 API 호출
            
               
            SearchService().searchMember(by: "id-and-nickname", keyword: query, page: 1, size: 20) { (result: Result<SearchMemberResponseDTO, NetworkError>) in
                switch result {
                case .success(let response):
                    let users = response.profilePreviews.map { member in
                        UserModel(
                            
                            clokeyId: member.clokeyId ?? "없는 사용자",
                            nickname: member.nickname ?? "없는 닉네임",
                            profileImage: member.profileImage ?? "없는 프로필"
                        )
                    }
                    
                    DispatchQueue.main.async {
                        self.query = query
                        self.users = users
                        self.filteredUsers = users
                        
                        
                        
                        //  검색 결과에 따라 emptyLabel 상태 변경
                        
                        
                        //  UI 업데이트
                        self.searchView.accountsCollectionView.reloadData()
                        self.updateEmptyLabel()
                        
                    }
                    
                case .failure(let error):
                    print("❌ 여기가 검색실팬가 검색 실패: \(error.localizedDescription)")
                }
            }
        } else {
            //  해시태그 검색 API 호출
            SearchService().searchHistory(by: "hashtag-and-category", keyword: query, page: 1, size: 20) { (result: Result<SearchHistoryCategoryResponseDTO, NetworkError>) in
                switch result {
                case .success(let response):
                    let newImages = response.historyPreviews.map { $0.imageUrl }
                    let newHistoryIDs: [Int] = response.historyPreviews.map { Int($0.id) }
                    
                    DispatchQueue.main.async {
                        self.query = query
                        self.dummyImages = newImages
                        self.dummyHistoryIDs = newHistoryIDs
                        
                        
                        
                        //  검색 결과에 따라 emptyLabel 상태 변경
                        self.searchView.emptyLabel.isHidden = !newImages.isEmpty
                        
                        //  UI 업데이트
                        self.searchView.hashtagsCollectionView.reloadData()
                        print(" Hashtags CollectionView Reloaded!")
                    }
                    
                case .failure(let error):
                    print("❌ 해시태그 검색 실패: \(error.localizedDescription)")
                }
            }
        }
        
        textField.resignFirstResponder() //  키보드 숨기기
        return true
    }
}

extension SearchResultViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == searchView.accountsCollectionView {
            return filteredUsers.count
        } else {
            return dummyImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == searchView.hashtagsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
                fatalError("ImageCell을 가져올 수 없음!")
            }
            let imageUrlString = dummyImages[indexPath.item]
            if let url = URL(string: imageUrlString) {
                cell.imageView.kf.setImage(with: url)
            }
            // dummyHistoryIDs 배열에서 historyId를 설정합니다.
            if dummyHistoryIDs.indices.contains(indexPath.item) {
                let historyId = dummyHistoryIDs[indexPath.item]
                cell.imageView.accessibilityIdentifier = "\(historyId)"
                
            } else {
                print(" dummyHistoryIDs에 \(indexPath.item) 인덱스 없음")
            }
            return cell
        } else if collectionView == searchView.accountsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.identifier, for: indexPath) as? UserCell else {
                fatalError(" UserCell을 가져올 수 없음!")
            }
            let user = filteredUsers[indexPath.item]
            cell.configure(with: user)
            return cell
        }
        fatalError("알 수 없는 컬렉션뷰")
        
    }
    // MARK: - UICollectionViewDelegate
    
    // collectionView의 didSelectItemAt에서 historyId를 추출하여 처리
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == searchView.hashtagsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCell,
                  let historyIdString = cell.imageView.accessibilityIdentifier,
                  let historyId = Int(historyIdString) else {
                print("historyId 못찾음")
                return
            }
            print("선택된 historyId: \(historyId)")
            fetchHistoryDetail(historyId: historyId)
        } // SearchResultViewController 내 didSelectItemAt
        else if collectionView == searchView.accountsCollectionView {
            let user = filteredUsers[indexPath.item]
            // 커스텀 이니셜라이저를 사용하여 인스턴스 생성
            let followProfileVC = FollowProfileViewController(followId: user.clokeyId)
            navigationController?.pushViewController(followProfileVC, animated: true)
        }
    }
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == searchView.accountsCollectionView {
            // 계정 컬렉션뷰: 레이아웃에서 지정한 크기와 동일하게
            return CGSize(width: UIScreen.main.bounds.width - 32, height: 46)
        } else if collectionView == searchView.hashtagsCollectionView {
            // 해시태그 컬렉션뷰: 레이아웃에서 지정한 크기와 동일하게
            return CGSize(width: UIScreen.main.bounds.width / 3, height: 172)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == searchView.accountsCollectionView {
            return 0  // accounts의 경우 delegate에서 별도의 interitem spacing을 설정하지 않음
        } else if collectionView == searchView.hashtagsCollectionView {
            return 0  // 해시태그 레이아웃에서 이미 0으로 설정
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == searchView.accountsCollectionView {
            return 16 // 계정 컬렉션뷰의 경우
        } else if collectionView == searchView.hashtagsCollectionView {
            return 0  // 해시태그 컬렉션뷰의 경우
        }
        return 0
    }
    
    // MARK: - History Detail Fetch
    
    private func fetchHistoryDetail(historyId: Int) {
        let historyService = HistoryService()
        
        historyService.historyDetail(historyId: historyId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                // 상세 정보 페이지로 이동
                let detailVC = FriendsCalendarDetailViewController()
                detailVC.setDetailData(response) // 상세 데이터 전달
                self.navigationController?.pushViewController(detailVC, animated: true)
                
            case .failure(let error):
                print("히스토리 상세 조회 실패: \(error.localizedDescription)")
            }
        }
    }
}

