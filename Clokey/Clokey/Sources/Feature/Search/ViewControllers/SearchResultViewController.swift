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



class SearchResultViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private let searchView = SearchResultView()
    private let searchManager = SearchManager()
    private var searchQuery: String?
    private var users: [UserModel] = [
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: ""),
        UserModel(clokeyId: "아이디2", nickname: "닉네임2", profileImage: ""),
        UserModel(clokeyId: "아이디3", nickname: "닉네임3", profileImage: ""),
        UserModel(clokeyId: "아이디4", nickname: "닉네임4", profileImage: ""),
        UserModel(clokeyId: "아이디5", nickname: "닉네임5", profileImage: ""),
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: ""),
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: ""),
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: ""),
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: ""),
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: ""),
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: ""),
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: ""),
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: ""),
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: ""),
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: ""),
        UserModel(clokeyId: "아이디1", nickname: "닉네임1", profileImage: "")
    ]
    private var dummyImages: [UIImage] = [
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample2") ?? UIImage(),
        UIImage(named: "sample3") ?? UIImage(),
        UIImage(named: "sample4") ?? UIImage(),
        UIImage(named: "sample5") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample1") ?? UIImage()
    ]
    private var filteredUsers: [UserModel] = []
    private var searchHistory: [String] = []
    
    // 서버 연결을 위한 변수들
    private var currentPage = 1
    private let pageSize = 20
    private var hasMorePages = true
    
    
    override func loadView() {
        view = searchView
    }
    init(searchQuery: String?) {
            self.searchQuery = searchQuery
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

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
        
        if let query = searchQuery {
            searchView.searchField.text = query
            filterUsers(with: query)
            addSearchHistory(query)
        }
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
        guard let data = searchView.searchField.text, !data.isEmpty else { return }
        let isAccountTab = sender == searchView.accountButton
        
        
        searchView.accountButton.setTitleColor(isAccountTab ? UIColor(named: "pointOrange800") : .lightGray, for: .normal)
        searchView.hashtagButton.setTitleColor(isAccountTab ? .lightGray : UIColor(named: "pointOrange800"), for: .normal)
        
        searchView.accountsCollectionView.isHidden = !isAccountTab
        searchView.hashtagsCollectionView.isHidden = isAccountTab
        
       
        UIView.animate(withDuration: 0.2) {
            self.searchView.indicatorView.snp.remakeConstraints { make in
                make.centerX.equalTo(sender.snp.centerX)
                make.bottom.equalTo(self.searchView.segmentedContainerView.snp.bottom).offset(-2)
                make.width.equalTo(88)
                make.height.equalTo(5)
            }
            self.view.layoutIfNeeded()
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
            cell.configure(with: dummyImages[indexPath.item])
            return cell
        }
    }
}

