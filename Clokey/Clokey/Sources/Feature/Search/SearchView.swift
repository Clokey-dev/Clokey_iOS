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
}

class SearchView: UIView {
    
    weak var delegate: SearchViewDelegate?

    // MARK: - UI Components
    let searchField = CustomSearchField() // 🔥 CustomSearchField 사용

    private var selectedButton: UIButton?

    let recentSearchTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
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
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let SearchTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "검색"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private let recentSearchLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 검색 기록"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let recommendedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "추천 검색어"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let recommendedScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
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
        setupRecommendedKeywords()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(searchField)
        addSubview(SearchTitleLabel)
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
            make.top.equalToSuperview().offset(74)
            make.leading.equalToSuperview().offset(19)
            make.width.height.equalTo(40)
        }
        
        SearchTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(74)
            make.leading.equalToSuperview().offset(49)
            make.width.equalTo(35)
            make.height.equalTo(24)
        }
        
        searchField.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(13)
            make.leading.trailing.equalToSuperview().inset(24)
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

    private func setupRecommendedKeywords() {
        for keyword in recommendedKeywords {
            let button = UIButton(type: .system)
            button.setTitle(keyword, for: .normal)
            button.setTitleColor(.black, for: .normal) // 기본 글씨색 검은색
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.backgroundColor = UIColor(red: 255/255, green: 231/255, blue: 210/255, alpha: 1) // 기본 배경색 RGBA(255, 231, 210, 1)
            button.layer.cornerRadius = 16
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
            
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchDragExit])
            button.addTarget(self, action: #selector(recommendedKeywordTapped(_:)), for: .touchUpInside)
            
            recommendedStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        sender.backgroundColor = UIColor(named: "mainOrange800")
        sender.setTitleColor(.white, for: .normal)
    }
    
    @objc private func recommendedKeywordTapped(_ sender: UIButton) {
        guard let keyword = sender.titleLabel?.text else { return }
        
        selectedButton?.backgroundColor = UIColor(red: 255/255, green: 231/255, blue: 210/255, alpha: 1)
        selectedButton?.setTitleColor(.black, for: .normal)

        sender.backgroundColor = UIColor(named: "mainOrange800")
        sender.setTitleColor(.white, for: .normal)

        selectedButton = sender

        delegate?.didTapRecommendedKeyword(keyword)
    }
    
    func resetRecommendedKeywords() {
        for case let button as UIButton in recommendedStackView.arrangedSubviews {
            button.backgroundColor = UIColor(red: 255/255, green: 231/255, blue: 210/255, alpha: 1)
            button.setTitleColor(.black, for: .normal)
        }
        selectedButton = nil
    }
}
