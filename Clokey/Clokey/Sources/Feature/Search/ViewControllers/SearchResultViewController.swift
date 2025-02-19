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


class SearchResultViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private let searchView = SearchResultView()
    private let searchManager = SearchManager()
    
    private var users: [UserModel]
    private var query: String
    
    var dummyImages: [String] = []
    private var filteredUsers: [UserModel] = []
    private var searchHistory: [String] = []
    private var initialTabIsHashtag: Bool = false
    
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
        loadSearchHistory()
        
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
        
        searchView.hashtagsCollectionView.reloadData()
        searchView.accountsCollectionView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchHistory = searchManager.fetchRecentSearches() //  검색 기록 강제 업데이트
        searchView.accountsCollectionView.reloadData()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        
        if offsetY > contentHeight - frameHeight - 100 {
            guard let query = searchView.searchField.text, !query.isEmpty else { return }
            
            loadMemberData(query: query, isNextPage: true)
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
        print("📂 불러온 검색 기록: \(searchHistory)")
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
        
        print("🔴 [Before] 기존 검색 기록: \(searchHistory)")
        
        //  중복 제거 후 맨 앞에 추가
        searchHistory.removeAll { $0 == query }
        searchHistory.insert(query, at: 0)
        
        //  최대 10개까지만 저장
        if searchHistory.count > 10 {
            searchHistory = Array(searchHistory.prefix(10))
        }
        
        UserDefaults.standard.setValue(searchHistory, forKey: "searchHistory")
        
        print("🟢 [After] 저장된 검색 기록: \(searchHistory)")
        
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
        guard hasMorePages else { return }
        
        let page = isNextPage ? currentPage + 1 : 1
        
        SearchService().searchHistory(by: "hashtag-and-category", keyword: query, page: page, size: pageSize) { [weak self] result in
            switch result {
            case .success(let response):
                let newImages = response.historyPreviews.map { $0.imageUrl }
                
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    //  기존 데이터 유지하면서 새 검색 결과만 추가
                    if isNextPage {
                        self.dummyImages.append(contentsOf: newImages)
                        self.currentPage = page
                    } else {
                        self.dummyImages = newImages
                        self.currentPage = 1
                    }
                    
                    //  새 검색 결과가 없을 때만 emptyLabel 보이도록 수정
                    self.searchView.emptyLabel.isHidden = !self.dummyImages.isEmpty
                    self.searchView.hashtagsCollectionView.reloadData()
                }
                
            case .failure(let error):
                print("❌ 해시태그 검색 실패: \(error.localizedDescription)")
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
        
        print(" 현재 입력 중: \(query)")
        
        //  계정 탭이 선택된 경우, 필터링 수행
        if !searchView.accountsCollectionView.isHidden {
            filterUsers(with: query)
        }
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension SearchResultViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text, !query.isEmpty else { return false }
        
        print(" [SearchResultViewController] 검색 실행: \(query) → 검색어 저장!")
        
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
                        
                        print("🔍 검색된 유저 수: \(users.count)")
                        print("📌 검색된 유저 목록: \(users)")
                        
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
                    
                    DispatchQueue.main.async {
                        self.query = query
                        self.dummyImages = newImages
                        
                        print("🔍 검색된 해시태그 수: \(newImages.count)")
                        print("📌 검색된 해시태그 목록: \(newImages)")
                        
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
        if collectionView == searchView.accountsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.identifier, for: indexPath) as? UserCell else {
                fatalError("❌ UserCell을 가져올 수 없음!")
            }
            let user = filteredUsers[indexPath.item]
            cell.configure(with: user)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
                fatalError("❌ ImageCell을 가져올 수 없음!")
            }
            
            //  이미지 URL을 Kingfisher로 로드
            let imageUrl = dummyImages[indexPath.item]
            if let url = URL(string: imageUrl) {
                cell.imageView.kf.setImage(with: url) //  URL에서 이미지 로드
            }
            
            return cell
        }
    }
}


