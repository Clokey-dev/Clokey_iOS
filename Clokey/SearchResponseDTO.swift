//
//  SearchResponseDTO.swift
//  Clokey
//
//  Created by 소민준 on 2/13/25.
//

import Foundation

//닉네임과 ID로 사용자 검색
public struct SearchMemberResponseDTO: Codable {
    public let memberPreviews: [MemberPreviewDTO]
    public let listsize: Int
    public let totalPage: Int
    public let totalElements: Int
    public let isFirst: Bool
    public let isLast: Bool
}

//memberpreviewDTO정의
public struct MemberPreviewDTO: Codable{
    public let id: Int64
    public let name: String
    public let clokeyId: String
    public let profileImage: String
}

//기록해시태그와 카테고리로 검색
public struct SearchHistoryCategoryResponseDTO: Codable{
    public let historyPreviews: [HistoryPreviewDTO]
    public let listSize: Int
    public let totalPage: Int
    public let totalElements: Int64
    public let isFirst: Bool
    public let isLast: Bool
}

public struct HistoryPreviewDTO: Codable{
    public let id: Int64
    public let imageUrl: String
}
// 옷장에서 검색
public struct SearchClothesResponseDTO: Codable{
    public let clothPreviews: [ClothPreviewDTO]
    public let totalPage: Int
    public let totalElements: Int64
    public let isFirst: Bool
    public let isLast: Bool
    
    
    
}

public struct ClothPreviewDTO: Codable{
    public let id: Int64
    public let name: String
    public let wearNum: Int
    public let imageUrl: String
}
