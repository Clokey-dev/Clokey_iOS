import Foundation
import Moya

public final class FolderService: NetworkManager {
    typealias Endpoint = FolderEndpoint
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<FolderEndpoint>
    
    public init(provider: MoyaProvider<FolderEndpoint>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            AccessTokenPlugin() // 필요에 따라 토큰 플러그인 사용
        ]
        self.provider = provider ?? MoyaProvider<FolderEndpoint>(plugins: plugins)
    }
    
    // MARK: - API funcs
    
    // 폴더별 옷 조회 GET API
    public func folderCheck(
        folderId: Int,
        page: Int,
        completion: @escaping (Result<FolderCheckResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .folderCheck(folderId: folderId, page: page),
            decodingType: FolderCheckResponseDTO.self,
            completion: completion
        )
    }
    
    // 전체 폴더 조회 GET API
    public func folderAll(
        page: Int,
        completion: @escaping (Result<FolderAllResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .folderAll(page: page),
            decodingType: FolderAllResponseDTO.self,
            completion: completion
        )
    }
    
    // 폴더 생성/관리 POST API
    public func folderManage(
        data: FolderManageRequestDTO,
        completion: @escaping (Result<FolderManageResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .folderManage(data: data),
            decodingType: FolderManageResponseDTO.self,
            completion: completion
        )
    }
    
    // 폴더 삭제 DELETE API
    public func folderDelete(
        folderId: Int,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        requestStatusCode(
            target: .folderDelete(folderId: folderId),
            completion: completion
        )
    }
}
