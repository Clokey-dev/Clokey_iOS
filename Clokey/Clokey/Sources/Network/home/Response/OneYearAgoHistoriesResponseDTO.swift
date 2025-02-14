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

// 소식 화면의 데이터 구조
public struct GetIssuesResponseDTO: Decodable {
    let recommend: [RecommendResponseDTO]
    let closet: [ClosetResponseDTO]
    let calendar: [CalendarResponseDTO]
    let people: [PeopleResponseDTO] // 현재 응답 예시에서는 빈 배열
}

// Recommend 섹션 항목
public struct RecommendResponseDTO: Decodable {
    let imageUrl: String?
    let subTitle: String
    let hashtag: String
    let date: String
}

// Closet 섹션 항목
public struct ClosetResponseDTO: Decodable {
    let clokeyId: String
    let profileImage: String
    let clothesId: [Int64]
    let images: [String]
    let date: String
}

// Calendar 섹션 항목
public struct CalendarResponseDTO: Decodable {
    let date: String
    let clokeyId: String
    let profileImage: String
    let events: [CalendarEventResponseDTO]
}

// Calendar 내 이벤트
public struct CalendarEventResponseDTO: Decodable {
    let historyId: Int64
    let imageUrl: String?
}

// People 섹션 (현재는 빈 배열이지만 확장 가능)
public struct PeopleResponseDTO: Decodable {
    // 필요한 필드가 없지만 추후 확장 가능
}

