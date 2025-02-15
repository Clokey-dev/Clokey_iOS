//
//  HistoryService.swift
//  Clokey
//
//  Created by 황상환 on 1/28/25.
//

import Foundation
import Moya

public final class HistoryService: NetworkManager {
    typealias Endpoint = HistoryEndpoint
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<HistoryEndpoint>
    
    public init(provider: MoyaProvider<HistoryEndpoint>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            AccessTokenPlugin()
        ]
        self.provider = provider ?? MoyaProvider<HistoryEndpoint>(plugins: plugins)
    }
    
    // MARK: - API funcs
    
    
    // 아이디 중복 확인 GET API
    public func historyMonth(
        clokeyId: String? = nil,
        month: String,
        completion: @escaping (Result<HistoryMonthResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .historyMonth(clokeyId: clokeyId, month: month),
            decodingType: HistoryMonthResponseDTO.self,
            completion: completion
        )
    }
    
    // 개별 기록 조회 GET API
    public func historyDetail(
        historyId: Int,
        completion: @escaping (Result<HistoryDetailResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .historyDetail(historyId: historyId),
            decodingType: HistoryDetailResponseDTO.self,
            completion: completion
        )
    }
    
    // 좋아요 POST API
    public func historyLike(
        data: HistoryLikeRequestDTO,
        completion: @escaping (Result<HistoryLikeResponseDTO,
            NetworkError>) -> Void
    ) {
        request(
            target: .historyLike(data: data),
            decodingType: HistoryLikeResponseDTO.self,
            completion: completion
        )
    }
    
    // 댓글 조회
    public func historyComment(
        historyId: Int,
        page: Int,
        completion: @escaping (Result<HistoryCommentsResponseDTO,
           NetworkError>) -> Void
    ) {
        request(
            target: .historyComments(historyId: historyId, page: page),
            decodingType: HistoryCommentsResponseDTO.self,
            completion: completion
        )
    }
    
    // 댓글 작성 POST API
    public func historyCommentWrite(
        historyId: Int,
        data: HistoryCommentWriteRequestDTO,
        completion: @escaping (Result<HistoryCommentWriteResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .historyCommentWrite(historyId: historyId, data: data),
            decodingType: HistoryCommentWriteResponseDTO.self,
            completion: completion
        )
    }
    
    // 댓글 삭제 DELETE API
    public func historyCommentDelete(
        commentId: Int,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        requestStatusCode(
            target: .historyCommentDelete(commentId: commentId),
            completion: completion
        )
    }
    
    // 댓글 수정 PATCH API
    public func historyCommentUpdate(
        commentId: Int,
        data: HistoryCommentUpdateRequestDTO,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        request(
            target: .historyCommentUpdate(commentId: commentId, data: data),
            decodingType: EmptyResponse.self,
            completion: { result in
                switch result {
                case .success:
                    completion(.success(())) // 성공 처리
                case .failure(let error):
                    completion(.failure(error)) // 실패 처리
                }
            }
        )
    }
    
    //  기록 삭제 DELETE API
    public func historyDelete(
        historyId: Int,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        requestStatusCode(
            target: .historyDelete(historyId: historyId),
            completion: completion
        )
    }
    
    // 좋아요 목록 조회 GET API
    public func historyLikeList(
        historyId: Int,
        completion: @escaping (Result<HistoryLikeListResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .historyLikeList(historyId: historyId),
            decodingType: HistoryLikeListResponseDTO.self,
            completion: completion
        )
    }
    
    // 히스토리 생성 POST API
    public func historyCreate(
        data: HistoryCreateRequestDTO,
        images: [Data],
        completion: @escaping (Result<HistoryCreateResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .historyCreate(data: data, images: images),
            decodingType: HistoryCreateResponseDTO.self,
            completion: completion
        )
    }
}


