//
//  FolderResponseDTO.swift
//  Clokey
//
//  Created by 한태빈 on 2/13/25.
//

import Foundation

// 폴더별 옷 조회
public struct FolderCheckResponseDTO: Codable {
    public let clothes: [FolderClothDTO]
}

public struct FolderClothDTO: Codable {
    public let clothId: Int
    public let clothName: String?
    public let imageUrl: String?
    public let clothCount: Int64
    
}

// 전체 폴더
public struct FolderAllResponseDTO: Codable {
    public let folders: [FolderDTO]
}

public struct FolderDTO: Codable {
    public let folderId: Int64
    public let folderName: String?
    public let imageUrl: String?
    public let itemCount: Int64
}

// 폴더 생성
public struct FolderManageResponseDTO: Codable {
    public let folderId: Int64
}

