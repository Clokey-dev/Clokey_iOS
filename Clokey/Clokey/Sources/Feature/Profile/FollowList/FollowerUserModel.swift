//
//  LikeUserModel.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import Foundation

struct FollowerUserModel {
    let userId: String
    let nickname: String
    let profileImageUrl: String
    var isFollower: Bool
}

struct FollowingUserModel {
    let userId: String
    let nickname: String
    let profileImageUrl: String
    var isFollowing: Bool
}
