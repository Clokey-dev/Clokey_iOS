import UIKit

struct DrawerModel {
    let id: Int64
    let title: String?
    let imageUrl: String?
    let itemCountText: String

    // computed property로 포맷팅 가능
    // var itemCountText: String {
    //     return "\(itemCount) 벌"
    // }
}

extension DrawerModel {
    // FolderDTO를 기반으로 DrawerItem을 생성하는 이니셜라이저
    init(dto: FolderDTO) {
        self.id = dto.folderId
        self.title = dto.folderName
        self.imageUrl = dto.imageUrl
        self.itemCountText = "아이템 : \(dto.itemCount)개"
    }
}

// DTO 배열을 DrawerItem 배열로 변환하는 헬퍼 메서드
extension Array where Element == FolderDTO {
    func toDrawerItems() -> [DrawerModel] {
        return self.map { DrawerModel(dto: $0) }
    }
}
