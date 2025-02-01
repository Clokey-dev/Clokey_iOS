//
//  HistoryResponseDTO.swift
//  Clokey
//
//  Created by 황상환 on 1/28/25.
//

import Foundation

//// 월별 기록 조회
public struct HistoryMonthResponseDTO: Codable {
    public let memberId: Int64
    public let histories: [HistoryDTO]
}

public struct HistoryDTO: Codable {
    public let historyId: Int
    public let date: String
    public let imageUrl: String
}

//// 일별 기록 조회
//public struct HistoryDayResponseDTO: Codable {
//    public let memberId: Int
//    public let memberImageUrl: String
//    public let nickname: String
////    public let clokeyId: long
//}

// 날짜 세부 페이지 
public struct HistoryDetailResponseDTO: Codable {
    public let memberId: Int64
    public let memberImageUrl: String
    public let nickName: String
    public let clokeyId: Int64
    public let content: String
    public let images: [String]
    public let hashtags: [String]
    public let availability: Bool
    public let likeCount: Int
    public let isLiked: Bool
    public let date: String
    public let clothes: [ClothDTO]
}

public struct ClothDTO: Codable {
    public let clothId: Int
    public let clothImageUrl: String
}
