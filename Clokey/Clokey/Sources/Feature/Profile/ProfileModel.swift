//
//  ProfileModel.swift
//  Clokey
//
//  Created by 한금준 on 1/27/25.
//

import UIKit

// 모델 정의
struct ProfileModel {
    let profileImageURLs: [String]
}

// 더미 데이터 관련 기능을 분리한 extension
extension ProfileModel {
    static func dummy() -> ProfileModel {
        return ProfileModel(
            profileImageURLs: [
                "https://img.danawa.com/prod_img/500000/436/224/img/17224436_1.jpg?_v=20220610092752",
                "https://www.ocokorea.com//upload/images/product/111/111888/Product_1670035608378.jpg",
                "https://item.elandrs.com/r/image/item/2023-10-13/fbb4c2ed-930a-4cb8-97e0-d4f287a1c971.jpg?w=750&h=&q=100"
            ]
        )
    }
}
