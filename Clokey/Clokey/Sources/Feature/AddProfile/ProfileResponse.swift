//
//  ProfileResponse.swift
//  Clokey
//
//  Created by 소민준 on 2/1/25.
//

import Foundation

struct ProfileResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ProfileResult?
}

struct ProfileResult: Codable {
    let id: Int
    let bio: String
    let email: String
    let nickname: String
    let clokeyId: String
    let profileImageUrl: String
    let profileBackImageUrl: String
    let visibility: String
    let updatedAt: String
}
