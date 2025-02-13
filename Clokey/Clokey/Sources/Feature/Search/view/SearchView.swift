//
//  SearchView.swift
//  Clokey
//
//  Created by 소민준 on 2/8/25.
//

import UIKit
import SnapKit

protocol SearchViewDelegate: AnyObject {
    func didTapRecommendedKeyword(_ keyword: String)
    func didTapBackButton()
}

class SearchView: UIView {
    
    private var keywordButtons: [UIButton] = [] // ✅ 추가
    weak var delegate: SearchViewDelegate?
    private var selectedButton: UIButton?
    private var recentSearches: [String] = []
    private var selectedKeyword: String?
    private let searchManager = SearchManager()
   
    
    // MARK: - UI Components
    let searchField = CustomSearchField()
    
    let recentSearchTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = true
        return tableView
    }()
    
    let deleteAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("전체삭제", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "goback"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let searchTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "검색"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    // 최근 검색 기록 라벨
    private let recentSearchLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 검색 기록"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    // 추천 검색어 타이틀
    private let recommendedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "추천 검색어"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    // 추천 검색어 스크롤 뷰
    private let recommendedScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    // 추천 검색어 스택 뷰
    private let recommendedStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()
    
    let recommendedKeywords = ["맨투맨", "스웨터", "연말룩", "바람막이", "코듀로이", "베이프", "스투시", "후드집업"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        loadRecentSearches()
        setupRecommendedKeywords()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSearchHistory), name: NSNotification.Name("SearchHistoryUpdated"), object: nil)
            
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        
        addSubview(searchField)
        addSubview(searchTitleLabel)
        addSubview(backButton)
        addSubview(recommendedTitleLabel)
        addSubview(recommendedScrollView)
        recommendedScrollView.addSubview(recommendedStackView)
        addSubview(recentSearchTableView)
        addSubview(deleteAllButton)
        addSubview(recentSearchLabel)
        
        setupConstraints()
    }
    
    
    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(10) // ✅ safeArea 적용 + 10pt 여백 추가
            make.leading.equalToSuperview().offset(19) // ✅ 왼쪽 19pt
            make.width.equalTo(10) // ✅ 10x20 사이즈
            make.height.equalTo(20)
        }
        
        
        searchTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY) // ✅ 높이를 `backButton`과 같은 라인에 정렬
            make.leading.equalTo(backButton.snp.trailing).offset(10) // ✅ 간격 조정
            make.height.equalTo(backButton.snp.height) // ✅ `backButton`과 같은 높이로 설정
        }
        
        searchField.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(23)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        recommendedTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(24)
        }
        
        recommendedScrollView.snp.makeConstraints { make in
            make.top.equalTo(recommendedTitleLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(38)
        }
        
        recommendedStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.width.greaterThanOrEqualToSuperview().priority(.low)
        }
        
        deleteAllButton.snp.makeConstraints { make in
            make.top.equalTo(recommendedTitleLabel.snp.bottom).offset(77)
            make.trailing.equalToSuperview().inset(16)
        }
        
        recentSearchLabel.snp.makeConstraints { make in
            make.top.equalTo(recommendedTitleLabel.snp.bottom).offset(77)
            make.leading.equalToSuperview().inset(24)
        }
        
        recentSearchTableView.snp.makeConstraints { make in
            make.top.equalTo(recentSearchLabel.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    func loadRecentSearches() {
        // ✅ 🔥 `fetchRecentSearches()` 호출해서 최신 데이터 가져오기
        recentSearches = searchManager.fetchRecentSearches()

        print("✅ [SearchView] 강제 업데이트된 검색 기록: \(recentSearches)")

        DispatchQueue.main.async {
            self.recentSearchTableView.reloadData() // ✅ UI 강제 업데이트
            self.recentSearchTableView.isHidden = self.recentSearches.isEmpty
        }
    }
    private func setupRecommendedKeywords() {
        for keyword in recommendedKeywords {
            let button = UIButton(type: .system)
            button.setTitle(keyword, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.backgroundColor = UIColor(red: 255/255, green: 231/255, blue: 210/255, alpha: 1)
            button.layer.cornerRadius = 16
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
            
            
            button.addTarget(self, action: #selector(recommendedKeywordTapped(_:)), for: .touchUpInside)
            
            recommendedStackView.addArrangedSubview(button)
            keywordButtons.append(button)
        }
    }
    @objc private func backButtonTapped() {
        print("✅ 뒤로 가기 버튼 클릭됨!") // 👉 로그 확인
        delegate?.didTapBackButton()
    }
    @objc private func recommendedKeywordTapped(_ sender: UIButton) {
        guard let keyword = sender.titleLabel?.text else { return }

        // ✅ 선택된 키워드를 저장 (UI 변경 X)
        UserDefaults.standard.setValue(keyword, forKey: "selectedKeyword")
        UserDefaults.standard.synchronize()

        // ✅ UI 변경 없이 검색만 실행
        delegate?.didTapRecommendedKeyword(keyword)
    }
    
  /*안돼ㅡㅡ  @objc private func recommendedKeywordTapped(_ sender: UIButton) {
        guard let keyword = sender.titleLabel?.text else { return }
        
        // ✅ 모든 버튼을 기본 색상으로 초기화
        for button in keywordButtons {
            button.backgroundColor = UIColor(red: 255/255, green: 231/255, blue: 210/255, alpha: 1)
            button.setTitleColor(.black, for: .normal)
        }
        
        // ✅ 현재 선택한 버튼의 색상 변경
        sender.backgroundColor = UIColor(named: "pointOrange800")
        sender.setTitleColor(.white, for: .normal)
        selectedButton = sender
        
        // ✅ 선택한 키워드 저장
        UserDefaults.standard.setValue(keyword, forKey: "selectedKeyword")
        UserDefaults.standard.synchronize()
        
        delegate?.didTapRecommendedKeyword(keyword)
    } */
    
    func updateSelectedKeywordUI() {
        let savedKeyword = UserDefaults.standard.string(forKey: "selectedKeyword")
        
        for button in keywordButtons {
            if button.titleLabel?.text == savedKeyword {
                // ✅ 저장된 키워드가 있으면 주황색
                button.backgroundColor = UIColor(red: 255/255, green: 231/255, blue: 210/255, alpha: 1)
                button.setTitleColor(.black, for: .normal)
               // button.backgroundColor = UIColor(named: "pointOrange800")
               // button.setTitleColor(.white, for: .normal)
                selectedButton = button
            } else {
                // ✅ 선택되지 않은 버튼들은 원래 색상으로 복구
                button.backgroundColor = UIColor(red: 255/255, green: 231/255, blue: 210/255, alpha: 1)
                button.setTitleColor(.black, for: .normal)
            }
        }
    }
    func updatePlaceholder(_ text: String) {
            searchField.setPlaceholder(text) // ✅ CustomSearchField의 setPlaceholder 호출
        }
    @objc private func updateSearchHistory() {
        print("✅ 검색 기록 업데이트 호출됨!")

        // ✅ 🔥 UserDefaults에서 최신 데이터 가져오기
        loadRecentSearches()
    }
    func removeSearchKeyword(_ keyword: String) {
        var searches = searchManager.fetchRecentSearches()
        
        // 🔥 검색어 삭제
        searches.removeAll { $0 == keyword }
        
        // 🔥 UserDefaults 갱신
        if searches.isEmpty {
            UserDefaults.standard.removeObject(forKey: "recentSearches")
        } else {
            UserDefaults.standard.set(searches, forKey: "recentSearches")
        }
        UserDefaults.standard.synchronize()

        print("🗑️ [SearchView] 삭제 후 검색 기록: \(searches)")

        // 🔥 ✅ UI 업데이트를 위해 `recentSearches` 직접 수정
        self.recentSearches = searches

        // 🔥 ✅ 테이블 뷰 UI 강제 업데이트
        DispatchQueue.main.async {
            self.recentSearchTableView.reloadData()
            self.recentSearchTableView.isHidden = self.recentSearches.isEmpty
        }

        // 🔥 ✅ NotificationCenter로 변경 사항 알림 (다른 화면에서도 반영되도록)
        NotificationCenter.default.post(name: NSNotification.Name("SearchHistoryUpdated"), object: nil)
    }
    func clearAllSearches() {
        searchManager.clearAllSearches()

        let checkSaved = searchManager.fetchRecentSearches()
        print("🗑️ [SearchView] 전체 삭제 후 검색 기록 확인: \(checkSaved)")

        DispatchQueue.main.async {
            self.recentSearches.removeAll() // ✅ 내부 데이터까지 제거
            self.recentSearchTableView.reloadData()
            self.recentSearchTableView.isHidden = true // ✅ 즉시 반영
        }

        NotificationCenter.default.post(name: NSNotification.Name("SearchHistoryUpdated"), object: nil)
    }
}
