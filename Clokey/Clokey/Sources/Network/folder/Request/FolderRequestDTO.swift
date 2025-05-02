import Foundation

public struct FolderManageRequestDTO: Codable {
    public let folderId: Int64?
    public let folderName: String?
    public let clothIds: [Int64]

    // CodingKeys를 정의 (디폴트 키 사용)
    enum CodingKeys: String, CodingKey {
        case folderId, folderName, clothIds
    }

    // folderId가 nil이면 JSON에서 해당 키를 생략하도록 커스텀 인코딩
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // folderId가 nil이 아닐 경우에만 JSON에 포함
        if let folderId = folderId {
            try container.encode(folderId, forKey: .folderId)
        }
        
        // folderName과 clothIds는 항상 포함
        try container.encode(folderName, forKey: .folderName)
        try container.encode(clothIds, forKey: .clothIds)
    }
}
