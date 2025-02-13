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
    
    private var dummyImages: [String] = []
    private var filteredUsers: [UserModel] = []
    private var searchHistory: [String] = []
    
    // 서버 연결을 위한 변수들
    private var currentPage = 1
    private let pageSize = 20
    private var hasMorePages = true
    
    
    override func loadView() {
        view = searchView
    }
    init(query: String, results: [UserModel]) {
            self.query = query
            self.users = results
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        searchView.accountsCollectionView.reloadData()
            // ✅ 네비게이션 바 스타일 설정
        
            
       
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
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchView.hashtagsCollectionView.reloadData()
        searchView.accountsCollectionView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchHistory = searchManager.fetchRecentSearches() // 🔥 검색 기록 강제 업데이트
        searchView.accountsCollectionView.reloadData()
    }
    
    @objc private func tabSelected(_ sender: UIButton) {
        guard !query.isEmpty else { return }
        let isAccountTab = sender == searchView.accountButton

        // ✅ UI 업데이트
        searchView.accountButton.setTitleColor(isAccountTab ? UIColor(named: "pointOrange800") : .lightGray, for: .normal)
        searchView.hashtagButton.setTitleColor(isAccountTab ? .lightGray : UIColor(named: "pointOrange800"), for: .normal)

        searchView.accountsCollectionView.isHidden = !isAccountTab
        searchView.hashtagsCollectionView.isHidden = isAccountTab

        // ✅ 탭 변경 시 API 호출
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
    
    
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
        print("📂 불러온 검색 기록: \(searchHistory)")
    }
    
    private func filterUsers(with query: String) {
        guard !query.isEmpty else {
            filteredUsers = users
            searchView.emptyLabel.isHidden = true
            searchView.accountsCollectionView.reloadData()
            return
        }
        
        filteredUsers = users.filter { user in
            let lowercasedQuery = query.lowercased()
            return user.clokeyId.lowercased().contains(lowercasedQuery) ||
            user.nickname.lowercased().contains(lowercasedQuery)
        }
        
        searchView.emptyLabel.isHidden = !filteredUsers.isEmpty
        searchView.accountsCollectionView.reloadData()
    }
    
    
    private func saveSearchQuery(_ query: String) {
        var searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []

        print("🔴 [Before] 기존 검색 기록: \(searchHistory)")

        // 🔥 중복 제거 후 맨 앞에 추가
        searchHistory.removeAll { $0 == query }
        searchHistory.insert(query, at: 0)

        // 🔥 최대 10개까지만 저장
        if searchHistory.count > 10 {
            searchHistory = Array(searchHistory.prefix(10))
        }

        UserDefaults.standard.setValue(searchHistory, forKey: "searchHistory")

        print("🟢 [After] 저장된 검색 기록: \(searchHistory)")

        // 🔥 검색 기록 다시 불러오고 UI 업데이트
        loadSearchHistory()
    }
    private func loadMemberData(query: String, isNextPage: Bool = false) {
        guard hasMorePages else { return }

        let page = isNextPage ? currentPage + 1 : 1

        SearchService().searchMemeber(data: query, page: 1, size: 20) { [weak self] result in
            switch result {
            case .success(let response):
                let users = response.memberPreviews.map { member in
                    UserModel(
                        clokeyId: member.clokeyId,
                        nickname: member.name,
                        profileImage: member.profileImage
                    )
                }

                DispatchQueue.main.async {
                    let resultVC = SearchResultViewController(query: query, results: users) // ✅ users 전달
                    self?.navigationController?.pushViewController(resultVC, animated: true)
                }

            case .failure(let error):
                print("❌ 검색 실패: \(error.localizedDescription)")
            }
        }
    }
    private func loadHistoryData(query: String, isNextPage: Bool = false) {
        guard hasMorePages else { return }

        let page = isNextPage ? currentPage + 1 : 1

        SearchService().searchHistory(data: query, page: page, size: pageSize) { [weak self] result in
            switch result {
            case .success(let response):
                let newImages = response.historyPreviews.map { $0.imageUrl } // 🔹 String URL 리스트 반환

                DispatchQueue.main.async {
                    if isNextPage {
                        self?.dummyImages.append(contentsOf: newImages) // ✅ URL을 추가할 수 있도록 수정
                        self?.currentPage = page
                    } else {
                        self?.dummyImages = newImages
                        self?.currentPage = 1
                    }

                    self?.hasMorePages = newImages.count >= self!.pageSize
                    self?.searchView.hashtagsCollectionView.reloadData()
                    self?.searchView.emptyLabel.isHidden = !self!.dummyImages.isEmpty
                }
            case .failure(let error):
                print("❌ 해시태그 검색 실패: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
            guard let query = textField.text, !query.isEmpty else { return }

            print("✅ 현재 입력 중: \(query)") // 👉 실시간 입력 확인 (하지만 저장하지 않음)

            filterUsers(with: query) // 🔥 자동완성 적용 (필터링만 수행)
        }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension SearchResultViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard let query = textField.text, !query.isEmpty else { return false }

            print("✅ [SearchResultViewController] 검색 실행: \(query) → 검색어 저장!")

            // 🔥 검색어 저장 추가
            searchManager.addSearchKeyword(query)

            // 🔥 검색 실행
            filterUsers(with: query)

            textField.resignFirstResponder() // 🔥 키보드 숨기기
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
            
            // ✅ 이미지 URL을 Kingfisher로 로드
            let imageUrl = dummyImages[indexPath.item]
            if let url = URL(string: imageUrl) {
                cell.imageView.kf.setImage(with: url) // ✅ URL에서 이미지 로드
            }
            
            return cell
        }
    }
}
