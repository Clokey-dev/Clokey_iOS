//
//  UpdateFriendCalendarModel.swift
//  Clokey
//
//  Created by 한금준 on 1/17/25.
//

// 완료

import UIKit

struct UpdateFriendCalendarModel{
    let imageUrl: URL
    let name: String
}

extension UpdateFriendCalendarModel {
    static func dummy() -> [UpdateFriendCalendarModel] {
        return [
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!, name: "히츄핑")
        ]
    }
}
