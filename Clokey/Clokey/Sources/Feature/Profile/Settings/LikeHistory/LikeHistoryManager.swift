//
//  LikeHistoryManager.swift
//  Clokey
//
//  Created by 소민준 on 3/11/25.
//


import Foundation

class LikeHistoryManager {
    private let likeHistoryKey = "likeHistory"
    
    // UserDefaults에서 좋아요 목록 불러오기
    func fetchLikeHistory() -> [String] {
        let savedItems = UserDefaults.standard.stringArray(forKey: likeHistoryKey) ?? []
        return savedItems
    }
    
    // 좋아요 목록 저장
    func saveLikeHistory(_ items: [String]) {
        UserDefaults.standard.set(items, forKey: likeHistoryKey)
        UserDefaults.standard.synchronize()
    }
    
    // 특정 아이템 삭제
    func removeItem(_ item: String) {
        var currentItems = fetchLikeHistory()
        currentItems.removeAll { $0 == item }
        saveLikeHistory(currentItems)
    }
    
    // 전체 삭제
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: likeHistoryKey)
        UserDefaults.standard.synchronize()
    }
}