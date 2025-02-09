//
//  SearchResultViewController.swift
//  Clokey
//
//  Created by 소민준 on 2/9/25.
//


//
//  SearchResultViewController.swift
//  Clokey
//
//  Created by 소민준 on 2/8/25.
//

import UIKit
import SnapKit

class SearchResultViewController: UIViewController {
    
    private let searchQuery: String
    private let resultsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    init(searchQuery: String) {
        self.searchQuery = searchQuery
        super.init(nibName: nil, bundle: nil)
        self.title = searchQuery // 검색어를 네비게이션 타이틀로 설정
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        fetchSearchResults()
    }
    
    private func setupUI() {
        view.addSubview(resultsLabel)
        
        resultsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func fetchSearchResults() {
        // TODO: 검색 결과 가져오는 API 호출할 예정
        resultsLabel.text = "'\(searchQuery)' 검색 결과가 없습니다."
    }
}