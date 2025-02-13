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
public struct AgreementToTermsResponseDTO: Codable {
    
    public let userId: Int
    public let terms: [Terms]
    
    public struct Terms: Codable {
        public let termId: Int
        public let agreed: Bool
    }
}

// 약관 조희
//public struct GetTermsResponseDTO: Codable {
//    public let terms: [Terms]
//    
//    public struct Terms: Codable {
//        public let termId: Int
//        public let title: String
//        public let content: String
//        public let optional: Bool
//    }
//}
public struct GetTermsResponseDTO: Codable {
    public let termId: Int
    public let title: String
    public let content: String
    public let optional: Bool
}

// 프로필 수정
public struct ProfileUpdateResponseDTO: Codable {
    public let id: Int
    public let bio: String
    public let email: String
    public let nickname: String
    public let clokeyId: String
    public let profileImageUrl: String
    public let profileBackImageUrl: String
    public let visibility: String
    public let updatedAt: String
    
}

// 
