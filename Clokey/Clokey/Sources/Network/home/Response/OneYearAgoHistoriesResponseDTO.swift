//
//  OneYearAgoHistoriesResponseDTO.swift
//  Clokey
//
//  Created by 한금준 on 2/2/25.
//

import Foundation

// Recap
public struct OneYearAgoHistoriesResponseDTO: Codable {
    let isMine: Bool
    let historyId: Int64?
    let nickName: String
    let imageUrls: [String] // 기존 코드

    enum CodingKeys: String, CodingKey {
        case isMine, historyId, nickName, imageUrls
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isMine = try container.decode(Bool.self, forKey: .isMine)
        historyId = try container.decodeIfPresent(Int64.self, forKey: .historyId)
        nickName = try container.decode(String.self, forKey: .nickName)
        imageUrls = try container.decodeIfPresent([String].self, forKey: .imageUrls) ?? [] // null이면 빈 배열로 처리
    }
}

public struct RecommendClothesResponseDTO: Codable {
    let recommendations: [Recommendation]

    struct Recommendation: Codable {
        let clothId: Int64
        let imageUrl: String
        let clothName: String
    }
}


//public struct GetDetailIssuesResponseDTO: Codable {
//    let closet: GetDetailIssuesClosetResponseDTO?
//    let calendar: GetDetailIssuesCalendarResponseDTO?
//}

// Closet 섹션용 DTO
public struct GetDetailIssuesClosetResponseDTO: Codable {
    let dailyNewsResult: [DailyNewsResult]
    let totalPage: Int
    let totalElements: Int
    let isFirst: Bool
    let isLast: Bool

    struct DailyNewsResult: Codable {
        let clokeyId: String
        let profileImage: String
        let clothesId: [Int64]?
        let images: [String]?
        let date: String
    }
}

// Calendar 섹션용 DTO
public struct GetDetailIssuesCalendarResponseDTO: Codable {
    let dailyNewsResult: [DailyNewsCalendarResult]
    let totalPage: Int
    let totalElements: Int
    let isFirst: Bool
    let isLast: Bool

    struct DailyNewsCalendarResult: Codable {
        let date: String
        let clokeyId: String
        let profileImage: String
        let events: [CalendarEventResponseDTO]?
    }

    struct CalendarEventResponseDTO: Codable {
        let historyId: Int64
        let imageUrl: String?
    }
}










// 소식 화면의 데이터 구조
public struct GetIssuesResponseDTO: Codable {
    let recommend: RecommendWrapperDTO
//    let recommend: [RecommendResponseDTO]
    let closet: ClosetWrapperDTO
    let calendar: CalendarWrapperDTO
    let people: PeopleWrapperDTO
}

// Recommend 섹션
public struct RecommendWrapperDTO: Codable {
    let innerResult: [RecommendResponseDTO]
}


public struct RecommendResponseDTO: Codable {
    let imageUrl: String?
    let subTitle: String
    let hashtag: String?
    let date: String
}

// Closet 섹션
public struct ClosetWrapperDTO: Codable {
    let innerResult: [ClosetResponseDTO]
}

public struct ClosetResponseDTO: Codable {
    let clokeyId: String
    let profileImage: String
    let clothesId: [Int64]
    let images: [String]
    let date: String
}

// Calendar 섹션
public struct CalendarWrapperDTO: Codable {
    let innerResult: [CalendarResponseDTO]
}

public struct CalendarResponseDTO: Codable {
    let date: String
    let clokeyId: String
    let profileImage: String
    let events: [CalendarEventResponseDTO]
}

// Calendar 내 이벤트
public struct CalendarEventResponseDTO: Codable {
    let historyId: Int64
    let imageUrl: String?
}

// People 섹션
public struct PeopleWrapperDTO: Codable {
    let innerResult: [PeopleResponseDTO]
}

public struct PeopleResponseDTO: Codable {
    let clokeyId: String
    let imageUrl: String
    let historyImage: String
    let historyId: Int64
}

