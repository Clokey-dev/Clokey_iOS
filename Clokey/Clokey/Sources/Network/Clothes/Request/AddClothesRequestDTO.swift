//
//  AddClothesRequestDTO.swift
//  NetworkTest
//
//  Created by 한금준 on 1/29/25.
//

import Foundation


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

    //  이미지 속성 제거 (Form-Data에서 따로 처리)
    
    enum CodingKeys: String, CodingKey {
        case categoryId, name, seasons, tempUpperBound, tempLowerBound, thicknessLevel, visibility, clothUrl, brand
    }
}

//  JSON을 "metadata" 키로 감싸도록 변환
extension AddClothesRequestDTO {
    func asMultipartMetadata() throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
        return ["metadata": dictionary ?? [:]] //  "metadata" 키로 감싸서 반환
    }
}



public struct EditClothesRequestDTO: Codable {
    public let categoryId: Int64
    public let name: String
    public let seasons: [String]
    public let tempUpperBound: Int
    public let tempLowerBound: Int
    public let thicknessLevel: String
    public let visibility: String
    public let clothUrl: String
    public let brand: String

    //  이미지 속성 제거 (Form-Data에서 따로 처리)
    
    enum CodingKeys: String, CodingKey {
        case categoryId, name, seasons, tempUpperBound, tempLowerBound, thicknessLevel, visibility, clothUrl, brand
    }
}

//  JSON을 "metadata" 키로 감싸도록 변환
extension EditClothesRequestDTO {
    func asMultipartMetadata() throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
        return ["metadata": dictionary ?? [:]] //  "metadata" 키로 감싸서 반환
    }
}



