//
//  TermsAgreementResponseDTO.swift
//  Clokey
//
//  Created by 황상환 on 1/27/25.
//

import Foundation

// 애플 로그인, 카카오 로그인, 약관 동의, 프로필 수정, 아이디 중복 확인 DTO 모음

// 카카오 로그인
public struct KakaoLoginResponseDTO: Codable {
    public let id: Int
    public let email: String
    public let nickname: String
    public let accessToken: String
    public let refreshToken: String
    public let registerStatus: String
}

// 약관 동의
public struct TermsAgreementResponseDTO: Codable {
    
    public let userId: Int
    public let terms: [Term]
    
    public struct Term: Codable {
        public let termId: Int
        public let agreed: Bool
    }
}

// 프로필 수정
public struct ProfileUpdateResponseDTO: Codable {
    public let id: Int
    public let bio: String
    public let email: String
    public let nickname: String
    public let clokeyId: String
    public let profileImageUrl: String
    public let updatedAt: String
    
}

// 
