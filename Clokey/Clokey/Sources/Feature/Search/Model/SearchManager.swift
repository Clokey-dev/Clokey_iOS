import Foundation

class SearchManager {
    
    private let recentSearchKey = "recentSearches"
    
    // ✅ 🔥 최근 검색어를 메모리에 저장 (UserDefaults랑 싱크 맞추기)
    private var recentSearches: [String] = []

    init() {
        // ✅ 초기화 시 `UserDefaults`에서 검색어 가져와서 `recentSearches`에 저장
        self.recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchKey) ?? []
    }

    // ✅ 🔥 최근 검색어 불러오기 (UserDefaults랑 싱크 맞추기)
    func fetchRecentSearches() -> [String] {
        let storedSearches = UserDefaults.standard.stringArray(forKey: recentSearchKey) ?? []
        
        // 🔥 `UserDefaults`와 메모리 데이터 싱크 맞추기
        if storedSearches.isEmpty {
            recentSearches.removeAll() // 🔥 최근 검색어 메모리에서도 삭제
        } else {
            recentSearches = storedSearches
        }

        print("✅ [SearchManager] fetchRecentSearches() 호출됨, 강제 최신화된 데이터: \(recentSearches)")
        return recentSearches
    }

    // ✅ 🔥 검색어 저장 (중복 제거)
    func addSearchKeyword(_ keyword: String) {
        var searches = fetchRecentSearches() // ✅ 최신 데이터 가져오기

        // ✅ 중복 제거 후 최신 검색어를 맨 위로 추가
        searches.removeAll { $0 == keyword }
        searches.insert(keyword, at: 0)

        // ✅ 검색 기록이 10개를 초과하면 가장 오래된 검색어 삭제
        if searches.count > 10 {
            searches.removeLast()
        }

        // ✅ UserDefaults에 저장
        UserDefaults.standard.set(searches, forKey: recentSearchKey)
        UserDefaults.standard.synchronize()

        print("✅ [SearchManager] 저장된 검색어 목록: \(searches)")

        // ✅ UI 업데이트 알림
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("SearchHistoryUpdated"), object: nil)
        }
    }
    // ✅ 🔥 특정 검색어 삭제
    func removeSearchKeyword(_ keyword: String) {
        var searches = fetchRecentSearches()
        
        // ✅ 🔥 삭제할 검색어 제거
        searches.removeAll { $0 == keyword }

        // ✅ 🔥 `UserDefaults` 업데이트
        if searches.isEmpty {
            UserDefaults.standard.removeObject(forKey: recentSearchKey)
        } else {
            UserDefaults.standard.set(searches, forKey: recentSearchKey)
        }
        UserDefaults.standard.synchronize()

        // ✅ 삭제 후 UserDefaults에 값이 남아있는지 확인
        let checkSaved = UserDefaults.standard.stringArray(forKey: recentSearchKey) ?? []
        print("🗑️ [SearchManager] 삭제 후 최종 저장된 검색 기록: \(checkSaved)")

        // ✅ UI 즉시 업데이트
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("SearchHistoryUpdated"), object: nil)
        }
    }
    // ✅ 🔥 전체 검색어 삭제
    // ✅ 🔥 전체 검색어 삭제 (UserDefaults가 즉시 업데이트 되도록 수정)
    func clearAllSearches() {
        UserDefaults.standard.removeObject(forKey: recentSearchKey)
        UserDefaults.standard.synchronize()

        // ✅ 🔥 내부 데이터도 초기화 (이전 값이 남지 않도록)
        recentSearches.removeAll()

        print("🗑️ [SearchManager] 전체 삭제 후 UserDefaults 확인: \(fetchRecentSearches())")

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("SearchHistoryUpdated"), object: nil)
        }
    }
}
