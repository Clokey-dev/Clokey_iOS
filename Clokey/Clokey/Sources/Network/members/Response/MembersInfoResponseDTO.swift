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
    public let profileImageUrl: String
    public let recordCount: Int
    public let followerCount: Int
    public let followingCount: Int
    public let nickname: String
    public let bio: String
    public let profileBackImageUrl: String
    public let visibility: String
    public let following: Bool
}

