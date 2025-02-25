//
//  InquiryClothesDetailResponseDTO.swift
//  NetworkTest
//
//  Created by 한금준 on 1/29/25.
//

import Foundation

// 옷 상세 조회(관리자용)
public struct InquiryClothesDetailResponseDTO: Codable {
    public let id: CLong
    public let name: String
    public let wearNum: Int
    public let seasons: [Season] // 수정된 부분
    public let tempUpperBound: Int
    public let tempLowerBound: Int
    public let thicknessLevel: [ThicknessLevel] // 수정된 부분
    public let visibility: [Visibility]        // 수정된 부분
    public let clothUrl: String
    public let brand: String
    public let imageUrl: String
    public let memberId: CLong
    public let categoryId: CLong
    public let createdAt: Date // 엔티티 생성 시간
    public let updatedAt: Date // 엔티티 수정 시간
}

// 옷 조회(수정용)
public struct checkEditClothesResponseDTO: Codable {
    public let id: Int64
    public let name: String
    public let seasons: [String]
    public let tempUpperBound: Int
    public let tempLowerBound: Int
    public let thicknessLevel: String
    public let visibility: String
    public let clothUrl: String?
    public let brand: String?
    public let imageUrl: String
    public let categoryId: Int64
}

// 옷 조회(팝업용)
public struct checkPopUpClothesResponseDTO: Codable {
    public let id: Int64
    public let regDate: String
    public let dayOfWeek: String
    public let imageUrl: String
    public let name: String
    public let seasons: [String]
    public let wearNum: Int
    public let visibility: String
    public let brand: String?
    public let clothUrl: String?
    public let category: String
}

// 카테고리별 옷 조회
public struct getCategoryClothesResponseDTO: Codable {
    public let id: CLong
    public let name: String
    public let wearNum: Int
    public let image: String
}

// 옷 추가
public struct AddClothesResponseDTO: Codable {
    public let id: Int64
}

// 유저 옷장 조회
public struct GetClothesByCategoryResponseDTO: Codable {
    public let clothPreviews: [ClothPreview]
    public let totalPage: Int
    public let totalElements: CLong
    public let isFirst: Bool
    public let isLast: Bool
}

public struct ClothPreview: Codable {
    public let id: CLong
    public let name: String
    public let wearNum: Int
    public let imageUrl: String
}

// 옷장에서 옷 이름과 브랜드로 검색
public struct ClothSearchResponseDTO: Codable {
    public let clothPreviews: [ClothPreview]
    public let totalPage: Int
    public let totalElements: CLong
    public let isFirst: Bool
    public let isLast: Bool
}

public struct SmartSummationResponseDTO: Codable {
    public let nickname: String
    public let frequentResult: SummaryClothPreviewDTO
    public let infrequentResult: SummaryClothPreviewDTO
}

public struct SummaryClothPreviewDTO: Codable {
    public let baseCategoryName: String  // 예: 상의, 하의, 아우터 등
    public let coreCategoryName: String  // 예: 셔츠/블라우스, 코트 등
    public let coreCategoryId: Int64
    public let usage: Int                // 일주일간 착용 횟수
    public let clothPreviews: [ClothPreviewDTO] // 옷 목록 (최대 3개)
}


