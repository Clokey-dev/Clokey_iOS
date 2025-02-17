//
//  AddClothesRequestDTO.swift
//  NetworkTest
//
//  Created by 한금준 on 1/29/25.
//

import Foundation

// 옷 추가
//public struct AddClothesRequestDTO: Codable {
//    public let categoryId: Int64
//    public let name: String
//    public let seasons: [String]
//    public let tempUpperBound: Int
//    public let tempLowerBound: Int
//    public let thicknessLevel: String
//    public let visibility: String
//    public let clothUrl: String
//    public let brand: String
//    
//    // ✅ 이미지 데이터는 Codable에서 제외하고, Form-Data로 보낼 때 따로 처리
//    public var image: Data?
//
//    enum CodingKeys: String, CodingKey {
//        case categoryId, name, seasons, tempUpperBound, tempLowerBound, thicknessLevel, visibility, clothUrl, brand
//    }
//}
public struct AddClothesRequestDTO: Codable {
    public let categoryId: Int64
    public let name: String
    public let seasons: [String]
    public let tempUpperBound: Int
    public let tempLowerBound: Int
    public let thicknessLevel: String
    public let visibility: String
    public let clothUrl: String
    public let brand: String

    // ✅ 이미지 속성 제거 (Form-Data에서 따로 처리)
    
    enum CodingKeys: String, CodingKey {
        case categoryId, name, seasons, tempUpperBound, tempLowerBound, thicknessLevel, visibility, clothUrl, brand
    }
}

// ✅ JSON을 "metadata" 키로 감싸도록 변환
extension AddClothesRequestDTO {
    func asMultipartMetadata() throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
        return ["metadata": dictionary ?? [:]] // ✅ "metadata" 키로 감싸서 반환
    }
}



// 옷 수정
public struct EditClothesRequestDTO: Codable {
    public let name: String
    public let season: [Season]
    public let tempUpperBound: Int
    public let tempLowerBound: Int
    public let thicknessLevel: [ThicknessLevel]
    public let visibility: [Visibility]
    public let clothUrl: String
    public let brand: String
}

public enum ThicknessLevel: String, Codable, CaseIterable {
    case light = "LIGHT"
    case medium = "MEDIUM"
    case thick = "THICK"
}

public enum Visibility: String, Codable, CaseIterable {
    case publicScope = "PUBLIC"
    case privateScope = "PRIVATE"
    case friendsOnly = "FRIENDS_ONLY"
}

public enum Season: String, Codable, CaseIterable {
    case spring = "SPRING"
    case summer = "SUMMER"
    case fall = "FALL"
    case winter = "WINTER"
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self) // Encodable 객체를 JSON 데이터로 변환
        let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] // JSON 데이터를 딕셔너리로 변환
        return dictionary ?? [:] // 변환된 딕셔너리 반환 (실패하면 빈 딕셔너리 반환)
    }
}
