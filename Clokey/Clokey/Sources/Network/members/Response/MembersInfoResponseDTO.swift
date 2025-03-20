//
//  MembersInfoResponseDTO.swift
//  Clokey
//
//  Created by 황상환 on 1/28/25.
//

import Foundation

// 회원 조회, 팔로우, 언팔로우, 회원탈퇴, 약관조회, 계정 공개 여부 조회

// 회원 조회
public struct MembersInfoResponseDTO: Codable {
    public let clokeyId: String
    public let profileImageUrl: String?
    public let recordCount: Int
    public let followerCount: Int
    public let followingCount: Int
    public let nickname: String
    public let bio: String
    public let profileBackImageUrl: String
    public let visibility: String
    public let clothResults: [ClothResult]
    public let isFollowing: Bool?
    
    public struct ClothResult: Codable {
        public let clothId: Int64?
        public let clothImage: String?
    }
}

public struct GetAgreedTermsResponseDTO: Codable {
    public let socialType: String
    public let email: String
    public let appVersion: String
    public let terms: [Terms]
    
    public struct Terms: Codable {
        public let termId: Int
        public let title: String
        public let agreed: Bool
    }
}

public struct GetFollowPeopleResponseDTO: Codable {
    let members: [Members]
    let totalPage: Int
    let totalElements: Int
    let isFirst: Bool
    let isLast: Bool

    struct Members: Codable {
        let nickname: String
        let clokeyId: String
        let profileImage: String
        let isFollowed: Bool
        let isMe: Bool
    }
}

// 본인 확인
public struct CheckMeResponseDTO: Codable {
    public let isMe: Bool
}
