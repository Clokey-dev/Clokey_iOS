//
//  AddClothesRequestDTO.swift
//  NetworkTest
//
//  Created by 한금준 on 1/29/25.
//

import Foundation

// 옷 추가
public struct AddClothesRequestDTO: Codable {
    public let name: String
    public let season: [Season]
    public let tempUpperBound: Int
    public let tempLowerBound: Int
    public let thicknessLevel: [ThicknessLevel]
    public let visibility: [Visibility]
    public let clothUrl: String
    public let brand: String
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
