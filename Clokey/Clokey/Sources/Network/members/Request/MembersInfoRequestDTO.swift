//
//  MembersInfoRequestDTO.swift
//  Clokey
//
//  Created by 황상환 on 1/28/25.
//

import Foundation

// 회원 조회, 팔로우, 언팔로우, 회원탈퇴, 약관조회, 계정 공개 여부 조회

// 회원 조회
public struct MembersInfoRequestDTO: Codable {
    public let clokeyId: String
}

// 팔로우
public struct FollowRequestDTO: Codable {
    public let myClokeyId: String
    public let yourClokeyId: String
}

// 언팔로우
public struct UnFollowRequestDTO: Codable {
    public let myClokeyId: String
    public let yourClokeyId: String
}
