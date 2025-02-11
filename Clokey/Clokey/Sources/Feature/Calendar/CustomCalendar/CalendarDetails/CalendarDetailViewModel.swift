//
//  CalendarDetailViewModel.swift
//  Clokey
//
//  Created by 황상환 on 2/7/25.
//

import Foundation

struct CalendarDetailViewModel {
    let memberId: Int64
    let profileImageURL: URL?
    let historyId: Int64
    let name: String
    let clokeyId: String
    let content: String
    let images: [String]
    let hashtags: String
    let visibility: Bool
    var liked: Bool
    var likeCount: String
    var commentCount: String
    let date: String
    let cloths: [ClothDTO]
    
    struct ClothDTO {
        let clothId: Int
        let imageUrl: String
        let name: String
    }

    init(data: HistoryDetailResponseDTO) {
        self.memberId = data.memberId
        self.profileImageURL = URL(string: data.memberImageUrl)
        self.historyId = data.historyId
        self.name = data.nickName
        self.clokeyId = data.clokeyId
        self.content = data.contents
        self.images = data.imageUrl
        self.hashtags = data.hashtags.joined(separator: " ")
        self.visibility = data.visibility
        self.liked = data.liked
        self.likeCount = "\(data.likeCount)"
        self.commentCount = "\(data.commentCount)"
        self.date = data.date
        self.cloths = data.cloths.map { ClothDTO(clothId: $0.clothId, imageUrl: $0.clothImageUrl, name: $0.clothName) }
    }
    
    // 좋아요 상태 업데이트를 위한 mutating 메서드
    mutating func updateLikeState(liked: Bool, likeCount: Int64) {
        self.liked = liked
        self.likeCount = "\(likeCount)"
    }
}
