//
//  Comment.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import Foundation

struct Comment: Identifiable {
    let id: Int
    let clokeyId: String
    let nickName: String
    let imageUrl: String
    let content: String
    let parentCommentId: Int?  // 대댓글이면 부모 댓글 ID, 일반 댓글이면 nil
}
