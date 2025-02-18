//
//  ProfileViewModel.swift
//  Clokey
//
//  Created by 한금준 on 2/17/25.
//

import Foundation

final class ProfileViewModel {
    static let shared = ProfileViewModel()

    private init() {
           self.userId = UserDefaults.standard.string(forKey: "userId") // ✅ 앱 실행 시 저장된 ID 불러오기
       }

    var userId: String? 
}
