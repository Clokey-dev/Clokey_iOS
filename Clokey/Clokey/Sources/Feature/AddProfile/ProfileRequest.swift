//
//  ProfileRequest.swift
//  Clokey
//
//  Created by 소민준 on 2/1/25.
//

import Foundation

struct ProfileRequest: Codable {
    let nickname: String
    let clokeyId: String
    let profileImageUrl: String
    let bio: String
    let profileBackImageUrl: String
    let visibility: String
}
