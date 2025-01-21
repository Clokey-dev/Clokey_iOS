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
                imageUrl: URL(string: "https://img.danawa.com/prod_img/500000/436/224/img/17224436_1.jpg?_v=20220610092752")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://img.danawa.com/prod_img/500000/436/224/img/17224436_1.jpg?_v=20220610092752")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://img.danawa.com/prod_img/500000/436/224/img/17224436_1.jpg?_v=20220610092752")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://img.danawa.com/prod_img/500000/436/224/img/17224436_1.jpg?_v=20220610092752")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://img.danawa.com/prod_img/500000/436/224/img/17224436_1.jpg?_v=20220610092752")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://img.danawa.com/prod_img/500000/436/224/img/17224436_1.jpg?_v=20220610092752")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://img.danawa.com/prod_img/500000/436/224/img/17224436_1.jpg?_v=20220610092752")!, name: "히츄핑"),
            UpdateFriendCalendarModel(
                imageUrl: URL(string: "https://img.danawa.com/prod_img/500000/436/224/img/17224436_1.jpg?_v=20220610092752")!, name: "히츄핑")
        ]
    }
}
