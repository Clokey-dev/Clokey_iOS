//
//  Comment.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import Foundation

struct Comment: Identifiable {
    let id: Int
    let memberId: Int
    let imageUrl: String
    let content: String
    let parentCommentId: Int?  // 대댓글이면 부모 댓글 ID, 일반 댓글이면 nil
}

extension Comment {
    static let sampleComments: [Comment] = [
        Comment(
            id: 1,
            memberId: 101,
            imageUrl: "https://example.com/images/user101.jpg",
            content: "이 게시글 정말 유익하네요!",
            parentCommentId: nil
        ),
        Comment(
            id: 2,
            memberId: 102,
            imageUrl: "https://example.com/images/user102.jpg",
            content: "맞아요! 저도 그렇게 생각해요.",
            parentCommentId: 1 // id=1에 대한 대댓글
        ),
        Comment(
            id: 3,
            memberId: 103,
            imageUrl: "https://example.com/images/user103.jpg",
            content: "동의합니다. 좋은 글이에요.",
            parentCommentId: 1 // id=1에 대한 대댓글
        ),
        Comment(
            id: 4,
            memberId: 103,
            imageUrl: "https://example.com/images/user103.jpg",
            content: "동의합니다. 좋은 글이에요.",
            parentCommentId: 1 // id=1에 대한 대댓글
        ),
        Comment(
            id: 5,
            memberId: 103,
            imageUrl: "https://example.com/images/user103.jpg",
            content: "동의합니다. 좋은 글이에요.",
            parentCommentId: 1 // id=1에 대한 대댓글
        ),
        Comment(
            id: 6,
            memberId: 104,
            imageUrl: "https://example.com/images/user104.jpg",
            content: "질문이 하나 있는데, 자세히 설명해 주실 수 있나요?",
            parentCommentId: nil
        ),
        Comment(
            id: 7,
            memberId: 104,
            imageUrl: "https://example.com/images/user104.jpg",
            content: "질문이 하나 있는데, 자세히 설명해 주실 수 있나요?",
            parentCommentId: nil
        )
    ]
}
