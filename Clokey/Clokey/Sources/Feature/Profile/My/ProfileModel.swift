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
                "https://sitem.ssgcdn.com/06/41/88/item/1000632884106_i2_500.jpg",
                "https://media.bunjang.co.kr/product/302229124_3_1732437776_w360.jpg",
                "https://shop-phinf.pstatic.net/20240812_256/1723418335896cT2a0_JPEG/9C6FB5A2-D293-46D0-BAF5-A74F48907B69.jpg"
            ]
        )
    }
}
