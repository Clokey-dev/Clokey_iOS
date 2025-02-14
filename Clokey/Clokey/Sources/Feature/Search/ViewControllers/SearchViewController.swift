//
//  SearchViewController.swift
//  Clokey
//
//  Created by 소민준 on 2/9/25.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController, UITextFieldDelegate, SearchViewDelegate {
    
    let searchView = SearchView()
    private let searchManager = SearchManager() // ✅ 검색 기록 관리 객체
    private var recentSearches: [String] = []
    private var selectedKeyword: String?
    private var searchHistory: [String] = []
    private let searchTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        

        searchView.delegate = self
        // ✅ 검색 기록 변경 시 자동 업데이트
        NotificationCenter.default.addObserver(self, selector: #selector(updateSearchHistory), name: NSNotification.Name("SearchHistoryUpdated"), object: nil)

        // ✅ SearchView 추가
        view.addSubview(searchView)
        
        
        searchView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        // ✅ Placeholder 변경
        searchView.updatePlaceholder("옷 유형, 아이디, 해시태그 ...")
        
        searchView.searchField.textField.delegate = self
        // ✅ Delegate & DataSource 설정 (테이블 뷰 업데이트 안 되는 문제 해결)
        searchView.recentSearchTableView.delegate = self
        searchView.recentSearchTableView.dataSource = self
        searchView.recentSearchTableView.register(RecentSearchCell.self, forCellReuseIdentifier: RecentSearchCell.identifier)

        // ✅ 검색 기록 전체 삭제 버튼 동작 설정
        searchView.deleteAllButton.addTarget(self, action: #selector(deleteAllSearches), for: .touchUpInside)

        // ✅ 검색 기록 로드
        loadRecentSearches()
    }
    // ✅ viewWillAppear에서 검색 기록을 강제 업데이트
    // ✅ 🔥 viewWillAppear()에서 불필요한 NotificationCenter 등록 정리
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
        searchView.searchField.textField.text = "" // ✅ 검색어 입력 필드 초기화

        // ✅ 🔥 기존 옵저버를 지우고 새로 추가하는 방식은 불필요 -> 한 번만 등록하면 됨
        loadRecentSearches()
    }
    // ✅ 검색 기록 불러오기
    func loadRecentSearches() {
        recentSearches = searchManager.fetchRecentSearches()
        searchHistory = recentSearches // ✅ 🔥 검색 기록을 최신화
        print("✅ [SearchViewController] 강제 업데이트된 검색 기록: \(recentSearches)")

        DispatchQueue.main.async {
            self.searchView.recentSearchTableView.reloadData()
            self.searchView.recentSearchTableView.isHidden = self.recentSearches.isEmpty
        }
    }
    // ✅ 뒤로 가기 버튼 동작
    func didTapBackButton() {
        print("✅ SearchViewController에서 뒤로 가기 실행!") // 👉 로그 확인
        navigationController?.popViewController(animated: true)
    }
    // ✅ 검색 기록이 변경될 때 자동 반영
    @objc private func updateSearchHistory() {
        print("✅ 검색 기록 업데이트 호출됨!")
        
        recentSearches = searchManager.fetchRecentSearches()
        searchHistory = recentSearches // ✅ 🔥 최신 검색 기록 반영
        print("🔴 [SearchViewController] 검색 기록 업데이트 후 최종 확인: \(recentSearches)")

        DispatchQueue.main.async {
            self.searchView.recentSearchTableView.reloadData()
            self.searchView.recentSearchTableView.isHidden = self.recentSearches.isEmpty
        }
    }
    @objc private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []

        print("✅ 최종 검색 기록 확인: \(searchManager.fetchRecentSearches())")
        DispatchQueue.main.async {
            if self.searchHistory.isEmpty {
                print("⚠️ 검색 기록 없음 → 테이블 뷰 숨김 처리!")
                self.searchView.recentSearchTableView.isHidden = true
            } else {
                print("✅ 검색 기록 있음 → 테이블 뷰 업데이트!")
                self.searchView.recentSearchTableView.isHidden = false
                self.searchView.recentSearchTableView.reloadData()
            }
        }
    
    
    }
    // ✅ 검색 기록 저장
    func saveRecentSearch(_ query: String) {
        searchManager.addSearchKeyword(query) // ✅ 중복 방지 및 최신화 포함
    }
    
    // ✅ 검색 실행
    // ✅ 검색 실행 함수 수정
    func performSearch(with query: String) {
        guard !query.isEmpty else { return }

        print("✅ [SearchViewController] 검색 실행: \(query) → 검색어 저장!")

        searchManager.addSearchKeyword(query) // ✅ 검색어 저장

        // ✅ 🔥 검색 기록 강제 반영
        searchHistory = searchManager.fetchRecentSearches()

        // ✅ 🔥 UI 업데이트를 위해 테이블 뷰 강제 리로드
        DispatchQueue.main.async {
            self.searchView.recentSearchTableView.reloadData()
            self.searchView.recentSearchTableView.isHidden = self.searchHistory.isEmpty
        }

        let resultVC = SearchResultViewController(searchQuery: query)
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    // ✅ 추천 검색어 클릭 시 실행 searchhistory
    func didTapRecommendedKeyword(_ keyword: String) {
        selectedKeyword = keyword // ✅ 선택한 키워드 저장
        UserDefaults.standard.set(keyword, forKey: "selectedKeyword") // ✅ 선택된 키워드 저장
        
        searchView.updateSelectedKeywordUI()
        searchView.searchField.textField.text = keyword
        performSearch(with: keyword)
    }
    
    // ✅ 검색창에서 "Enter" 키 입력 시 실행 searchmemeberapi 호출
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text, !query.isEmpty else { return false }

        print("✅ 검색 실행: \(query)") // 👉 검색 버튼 눌렀을 때만 저장

        performSearch(with: query) // 검색 실행
        textField.resignFirstResponder()
        return true
    }
    
    // ✅ 검색 기록 전체 삭제
    @objc private func deleteAllSearches() {
        print("🗑️ [SearchViewController] 전체 삭제 버튼 클릭됨!")

        searchManager.clearAllSearches()
        searchHistory.removeAll()

        DispatchQueue.main.async {
            self.searchView.recentSearchTableView.reloadData()
            self.searchView.recentSearchTableView.isHidden = true // ✅ UI 즉시 업데이트
        }
    }
    
}

// ✅ 최근 검색어 목록을 위한 UITableView 구현
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("✅ [SearchViewController] 테이블 뷰 데이터 개수: \(searchHistory.count)")
        return searchHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell", for: indexPath) as! RecentSearchCell
        cell.titleLabel.text = searchHistory[indexPath.row]

        // ✅ 삭제 버튼 클릭 시 동작 추가
        // ✅ 삭제 버튼 클릭 시 동작 수정
        cell.deleteAction = { [weak self] in
            guard let self = self else { return }
            let keywordToDelete = self.searchHistory[indexPath.row]

            self.searchManager.removeSearchKeyword(keywordToDelete)

            // ✅ 🔥 삭제 후 즉시 `searchHistory` 갱신
            self.searchHistory = self.searchManager.fetchRecentSearches()

            DispatchQueue.main.async {
                self.searchView.recentSearchTableView.reloadData()
                self.searchView.recentSearchTableView.isHidden = self.searchHistory.isEmpty
            }
        }

        print("✅ [SearchViewController] 테이블 뷰 셀 생성: \(searchHistory[indexPath.row])")
        return cell
    }

    
    
    // ✅ 최근 검색어 클릭 시 검색 실행 searchmember호출
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedQuery = recentSearches[indexPath.row]
        performSearch(with: selectedQuery)
    }
    
    
    // ✅ 최근 검색어 셀 정의
    class RecentSearchCell: UITableViewCell {
        static let identifier = "RecentSearchCell"
        
        let titleLabel = UILabel()
        
        private let iconImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "clock_icon") // 최근 검색 아이콘
            imageView.tintColor = .lightGray
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        private let deleteButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("✕", for: .normal)
            button.setTitleColor(.black, for: .normal)
            return button
        }()
        
        var deleteAction: (() -> Void)?
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        private func setupUI() {
            contentView.addSubview(titleLabel)
            contentView.addSubview(deleteButton)
            contentView.addSubview(iconImageView)
            
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
            
            iconImageView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(12)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(20) // 크기 조정
            }
            titleLabel.snp.makeConstraints { make in
                make.leading.equalTo(iconImageView.snp.trailing).offset(10)
                make.centerY.equalToSuperview()
            }
            
            deleteButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(14)
                make.centerY.equalToSuperview()
            }
        }
        
        @objc private func didTapDelete() {
            if let text = titleLabel.text {
                print("🗑️ [RecentSearchCell] 삭제 요청: \(text)")
                deleteAction?() // ✅ 삭제 요청 보내기
            }
        }
        
        
    }
}

