//
//  AddProfileViewModel.swift
//  Clokey
//
//  Created by 소민준 on 1/26/25.
//


import Foundation

final class AddProfileViewModel {
    
    // 사용자 정보 저장 (일단은 메모리에서만 저장)
    private var userInfo: (nickname: String, id: String, accountType: String)?
    
    // MARK: - Methods
    // 사용자가 프로필을 완료하고 가입 정보를 처리하는 메서드
    func handleUserSignUp(nickname: String, id: String, accountType: String) {
        // 여기에 실제 서버 연동 코드를 넣을 수 있습니다.
        
        // 일단은 사용자 정보 로컬에 저장
        userInfo = (nickname: nickname, id: id, accountType: accountType)
        
        // 디버깅용 출력
        print("가입 완료: \(nickname), \(id), \(accountType)")
    }
    
    // 사용자 정보 확인 (디버깅 용도)
    func getUserInfo() -> (nickname: String, id: String, accountType: String)? {
        return userInfo
    }
}
