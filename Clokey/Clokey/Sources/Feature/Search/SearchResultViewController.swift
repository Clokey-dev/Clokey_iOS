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

class SearchResultViewController: UIViewController, UICollectionViewDelegate {
    let searchField = CustomSearchField()
    var searchQuery: String?
    let searchManager = SearchManager()
    var searchHistory: [String] = []
    enum TabType {
        case account
        case hashtag
    }
    private var users: [UserModel] = [
        UserModel(userId: "아이디1", nickname: "닉네임1", profileImageUrl: ""),
        UserModel(userId: "아이디2", nickname: "닉네임2", profileImageUrl: ""),
        UserModel(userId: "아이디3", nickname: "닉네임3", profileImageUrl: ""),
        UserModel(userId: "아이디4", nickname: "닉네임4", profileImageUrl: ""),
        UserModel(userId: "아이디5", nickname: "닉네임5", profileImageUrl: "")
    ]
    private var dummyImages: [UIImage] = [
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample2") ?? UIImage(),
        UIImage(named: "sample3") ?? UIImage(),
        UIImage(named: "sample4") ?? UIImage(),
        UIImage(named: "sample5") ?? UIImage()
    ]
    
    // 🔹 뒤로 가기 버튼
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "goback"), for: .normal) // ✅ goBack 이미지 사용
        button.contentMode = .scaleAspectFit
        return button
    }()
    let searchTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "검색"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold) // ✅ 크기 20
        label.textColor = .black
        return label
    }()

    
    // 🔹 탭 버튼 컨테이너
    private let segmentedContainerView = UIView()
    
    // 🔹 계정 버튼
    private let accountButton = UIButton(type: .system).then {
        $0.setTitle("계정", for: .normal)
        $0.setTitleColor(UIColor(named: "pointOrange800"), for: .normal) // 기본 선택 상태
        $0.titleLabel?.font = UIFont.ptdBoldFont(ofSize: 20)
    }
    
    // 🔹 해시태그 버튼
    private let hashtagButton = UIButton(type: .system).then {
        $0.setTitle("해시태그", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal) // 기본 비선택 상태
        $0.titleLabel?.font = UIFont.ptdBoldFont(ofSize: 20)
    }
    
    
    
    
    // 🔹 탭 구분선 추가
    private let separatorLine = UIView().then {
        $0.backgroundColor = .lightGray
    }
    
    // 🔹 인디케이터
    private let indicatorView = UIView().then {
        $0.backgroundColor = UIColor(named: "pointOrange800")
        $0.layer.cornerRadius = 2
    }
    // 🔹 검색 결과 CollectionView
    //private let accountsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let accountsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 70) // ✅ 크기 조정
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16) // ✅ 여백 추가
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.identifier) // ✅ 등록 확인
        return collectionView
    }()
    private let hashtagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // 🔹 검색 결과 없음 표시
    private let emptyLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다."
        $0.textColor = .gray
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private var selectedTab: TabType = .account // 기본값을 계정으로 설정
    private var filteredUsers: [UserModel] = []
    init(searchQuery: String) {
        self.searchQuery = searchQuery
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupCollectionViews()
        setupActions()
        setupActions() // ✅ 버튼 이벤트 정상 작동하도록 추가
        accountsCollectionView.delegate = self
        accountsCollectionView.dataSource = self
        hashtagsCollectionView.delegate = self
        hashtagsCollectionView.dataSource = self
        loadSearchHistory()
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchField.delegate = self // 🔥 UITextFieldDelegate 설정
        
        
        
        // 🔹 검색어 필터링 적용
        if let query = searchQuery {
                searchField.text = query
                filterUsers(with: query)

                // 🔥 🔥 🔥 검색 기록에 저장 추가
                searchManager.addSearchKeyword(query)
            }
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchHistory = searchManager.fetchRecentSearches() // 🔥 검색 기록 강제 업데이트
        accountsCollectionView.reloadData()
    }
    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(searchField)
        view.addSubview(segmentedContainerView)
        view.addSubview(searchTitleLabel)
        segmentedContainerView.addSubview(accountButton)
        segmentedContainerView.addSubview(hashtagButton)
        segmentedContainerView.addSubview(indicatorView)
        view.addSubview(accountsCollectionView)
        view.addSubview(hashtagsCollectionView)
        view.addSubview(emptyLabel)
        view.addSubview(separatorLine)
        
        // 🔹 뒤로 가기 버튼
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10) // ✅ safeArea 적용 + 10pt 여백 추가
            make.leading.equalToSuperview().offset(19) // ✅ 왼쪽 19pt
            make.width.equalTo(10) // ✅ 10x20 사이즈
            make.height.equalTo(20)
        }

        searchTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton) // ✅ 뒤로가기 버튼과 같은 높이
            make.leading.equalTo(backButton.snp.trailing).offset(20) // ✅ 20pt 간격
        }

        // 🔹 검색창 위치 조정
        searchField.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(25) // ✅ 기존 25 → 15로 줄여서 조정
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }

        // 🔹 탭 버튼과 구분선 위치 조정
        separatorLine.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(segmentedContainerView.snp.bottom).offset(2)
            make.height.equalTo(0.5)
        }
        
        
        // 🔹 탭 버튼 컨테이너
        segmentedContainerView.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        accountButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        hashtagButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        indicatorView.snp.makeConstraints { make in
            make.centerX.equalTo(accountButton.snp.centerX)
            make.bottom.equalTo(self.separatorLine.snp.centerY) // 🔥 밑줄 위로 배치
            make.width.equalTo(88)
            make.height.equalTo(5)
        }
        
        accountsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedContainerView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        hashtagsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedContainerView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 초기 상태
        accountsCollectionView.isHidden = false
        hashtagsCollectionView.isHidden = true
    }
    
    private func setupCollectionViews() {
        let hashtagLayout = UICollectionViewFlowLayout()
        hashtagLayout.scrollDirection = .vertical
        hashtagLayout.minimumLineSpacing = 0 // ✅ 셀 간 간격 없애기
        hashtagLayout.minimumInteritemSpacing = 0 // ✅ 셀 사이 간격 없애기
        hashtagLayout.sectionInset = .zero // ✅ 여백 없애기
        hashtagLayout.itemSize = CGSize(width: 131, height: 172) // ✅ 셀 크기 고정

        hashtagsCollectionView.collectionViewLayout = hashtagLayout
        hashtagsCollectionView.delegate = self
        hashtagsCollectionView.dataSource = self
        hashtagsCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
    }
    private func setupActions() {
        accountButton.addTarget(self, action: #selector(tabSelected(_:)), for: .touchUpInside)
        hashtagButton.addTarget(self, action: #selector(tabSelected(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    @objc private func tabSelected(_ sender: UIButton) {
        if sender == accountButton {
            accountButton.setTitleColor(UIColor(named: "pointOrange800"), for: .normal)
            hashtagButton.setTitleColor(.lightGray, for: .normal)
            accountsCollectionView.isHidden = false
            hashtagsCollectionView.isHidden = true
        } else {
            accountButton.setTitleColor(.lightGray, for: .normal)
            hashtagButton.setTitleColor(UIColor(named: "pointOrange800"), for: .normal)
            accountsCollectionView.isHidden = true
            hashtagsCollectionView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.2) {
            self.indicatorView.snp.remakeConstraints { make in
                make.centerX.equalTo(sender.snp.centerX) // ✅ 선택된 버튼의 중심으로 이동
                make.bottom.equalTo(self.separatorLine.snp.centerY) // ✅ 기존 선 위에서 움직이도록 조정
                make.width.equalTo(88)
                make.height.equalTo(5)
            }
            self.view.layoutIfNeeded()
        }
    }
    // 검색 기록 저장
    
    
    // 🔹 검색 기록 저장 함수 (중복 저장 방지)
    private func addSearchHistory(_ query: String) {
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
        accountsCollectionView.reloadData()
    }
    // 🔹 뒤로가기 버튼
    @objc private func didTapBackButton() {
        NotificationCenter.default.post(name: NSNotification.Name("SearchHistoryUpdated"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    // 검색 기록 불러오기
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
    }
    func filterUsers(with query: String) {
        guard !query.isEmpty else {
            filteredUsers = users
            emptyLabel.isHidden = true
            accountsCollectionView.reloadData()
            return
        }
        
        filteredUsers = users.filter { user in
            let lowercasedQuery = query.lowercased()
            return user.userId.lowercased().contains(lowercasedQuery) ||
            user.nickname.lowercased().contains(lowercasedQuery)
        }
        
        emptyLabel.isHidden = !filteredUsers.isEmpty
        accountsCollectionView.reloadData()
    }
    
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let query = textField.text, !query.isEmpty else { return }

        print("✅ 현재 입력 중: \(query)") // 👉 실시간 입력 확인 (하지만 저장하지 않음)

        filterUsers(with: query) // 🔥 자동완성 적용 (필터링만 수행)
    }
    func removeSearchHistory(_ query: String) {
        var searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []

        print("🗑️ [Before] 삭제 전 검색 기록: \(searchHistory)")

        searchHistory.removeAll { $0 == query } // 🔥 선택한 검색어 삭제

        UserDefaults.standard.setValue(searchHistory, forKey: "searchHistory")

        print("🗑️ [After] 삭제 후 검색 기록: \(searchHistory)")

        // 🔥 검색 기록 다시 불러와서 UI 업데이트
        loadSearchHistory()
        accountsCollectionView.reloadData()
    }
    
}
// MARK: - UICollectionViewDataSource
// MARK: - UICollectionViewDataSource
// ✅ 엔터(완료) 눌렀을 때만 검색어 저장
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
extension SearchResultViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == accountsCollectionView {
            return filteredUsers.count
        } else {
            return dummyImages.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == accountsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.identifier, for: indexPath) as? UserCell else {
                fatalError("❌ UserCell을 가져올 수 없음! register가 안 됐거나 identifier가 잘못되었을 가능성이 있음.")
            }
            let user = filteredUsers[indexPath.item]
            cell.configure(with: user)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
                fatalError("❌ ImageCell을 가져올 수 없음! register가 안 됐거나 identifier가 잘못되었을 가능성이 있음.")
            }
            if indexPath.item < dummyImages.count {
                cell.configure(with: dummyImages[indexPath.item])
            }
            return cell
        }
    }
}
