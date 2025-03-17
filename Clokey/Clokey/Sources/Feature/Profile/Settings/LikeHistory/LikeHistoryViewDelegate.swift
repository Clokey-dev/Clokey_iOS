//
//  LikeHistoryViewDelegate.swift
//  Clokey
//
//  Created by 소민준 on 3/11/25.
//


import Foundation

protocol LikeHistoryViewDelegate: AnyObject {
    func didTapBackButton()
    func didSelectLikeItem(_ item: String) // 필요 시 선택 아이템 이벤트 전달
}