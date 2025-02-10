//
//  SearchManager.swift
//  Clokey
//
//  Created by 소민준 on 2/8/25.
//

import Foundation

class SearchManager {
    
    private let recentSearchKey = "recentSearches"

    // ✅ 최근 검색어 불러오기
    func fetchRecentSearches() -> [String] {
        return UserDefaults.standard.stringArray(forKey: recentSearchKey) ?? []
    }

    // ✅ 검색어 저장 (중복 제거)
    func addSearchKeyword(_ keyword: String) {
        var searches = fetchRecentSearches()
        if let index = searches.firstIndex(of: keyword) {
            searches.remove(at: index) // 기존 검색어 삭제 후 추가 (중복 방지)
        }
        searches.insert(keyword, at: 0) // 최신 검색어가 위로 올라오도록 삽입
        UserDefaults.standard.set(searches, forKey: recentSearchKey)
    }

    // ✅ 특정 검색어 삭제
    func removeSearchKeyword(_ keyword: String) {
        var searches = fetchRecentSearches()
        searches.removeAll { $0 == keyword }
        UserDefaults.standard.set(searches, forKey: recentSearchKey)
    }

    // ✅ 전체 검색어 삭제
    func clearAllSearches() {
        UserDefaults.standard.set([], forKey: recentSearchKey)
    }
}