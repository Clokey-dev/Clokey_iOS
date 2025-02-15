//
//  PickImageModel.swift
//  Clokey
//
//  Created by 한금준 on 1/19/25.
//

import UIKit

// 모델 정의
struct PickImageModel {
    let weatherImageURLs: [String]
    let recapImageURLs: [String]
}

// 더미 데이터 관련 기능을 분리한 extension
extension PickImageModel {
    static func dummy() -> PickImageModel {
        return PickImageModel(
            weatherImageURLs: [
                "https://sitem.ssgcdn.com/06/41/88/item/1000632884106_i2_500.jpg",
                "https://media.bunjang.co.kr/product/302229124_3_1732437776_w360.jpg",
                "https://shop-phinf.pstatic.net/20240812_256/1723418335896cT2a0_JPEG/9C6FB5A2-D293-46D0-BAF5-A74F48907B69.jpg"
            ],
            recapImageURLs: [
                "https://m.jnmimi.com/web/product/medium/202501/4e5087f51c67f8c0cb3297f12500125c.png",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJptKUAdOTnHLNgHMTWd7Grx1EEKwJq8hkU8T-RXNGHvalk1tr"
            ]
        )
    }
}
