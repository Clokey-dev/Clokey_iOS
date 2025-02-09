//
//  SearchViewController.swift
//  Clokey
//
//  Created by 소민준 on 2/8/25.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController, UITextFieldDelegate, SearchViewDelegate {
    
    let searchView = SearchView()
    private var recentSearches: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(searchView)
        
        searchView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        searchView.delegate = self
        searchView.searchField.textField.delegate = self
        searchView.recentSearchTableView.delegate = self
        searchView.recentSearchTableView.dataSource = self
        searchView.recentSearchTableView.register(RecentSearchCell.self, forCellReuseIdentifier: RecentSearchCell.identifier)
        
        searchView.deleteAllButton.addTarget(self, action: #selector(deleteAllSearches), for: .touchUpInside)
        
        loadRecentSearches()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        searchView.searchField.textField.text = ""
        loadRecentSearches()
    }
    
    func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
        searchView.recentSearchTableView.reloadData()
        searchView.recentSearchTableView.isHidden = recentSearches.isEmpty
    }
    
    func saveRecentSearch(_ query: String) {
        if !recentSearches.contains(query) {
            recentSearches.insert(query, at: 0)
            UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
        }
    }
    
    @objc private func deleteAllSearches() {
        recentSearches.removeAll()
        UserDefaults.standard.set([], forKey: "recentSearches")
        loadRecentSearches()
    }
    
    func performSearch(with query: String) {
        guard !query.isEmpty else { return }
        saveRecentSearch(query)
        
        searchView.searchField.textField.text = query
        searchView.recentSearchTableView.reloadData()

        let resultVC = SearchResultViewController(searchQuery: query)
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func didTapRecommendedKeyword(_ keyword: String) {
        searchView.searchField.textField.text = keyword
        performSearch(with: keyword)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text, !query.isEmpty else { return false }
        performSearch(with: query)
        textField.resignFirstResponder()
        return true
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell", for: indexPath) as! RecentSearchCell
        cell.titleLabel.text = recentSearches[indexPath.row]

        cell.deleteAction = { [weak self] in
            self?.recentSearches.remove(at: indexPath.row)
            UserDefaults.standard.set(self?.recentSearches, forKey: "recentSearches")
            self?.loadRecentSearches()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedQuery = recentSearches[indexPath.row]
        performSearch(with: selectedQuery)
    }
}

class RecentSearchCell: UITableViewCell {
    static let identifier = "RecentSearchCell"
    
    let titleLabel = UILabel()
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
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func didTapDelete() {
        deleteAction?()
    }
}