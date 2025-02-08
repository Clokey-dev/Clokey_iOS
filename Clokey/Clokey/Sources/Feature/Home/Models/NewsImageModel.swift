//
//  NewsImageModel.swift
//  Clokey
//
//  Created by 한금준 on 1/19/25.
//

import Foundation

// News 화면에 사용되는 이미지 URL 데이터를 관리하는 모델
struct NewsImageModel {
    let clothesImageURLs: [String]
    let calendarImageURLs: [String]
    let hotImageURLs: [String]
}

// NewsImageModel에 더미 데이터를 제공하는 extension
extension NewsImageModel {
    static func dummy() -> NewsImageModel {
        return NewsImageModel(
            clothesImageURLs: [
                "https://img.danawa.com/prod_img/500000/436/224/img/17224436_1.jpg?_v=20220610092752",
                "https://www.ocokorea.com//upload/images/product/111/111888/Product_1670035608378.jpg",
                "https://item.elandrs.com/r/image/item/2023-10-13/fbb4c2ed-930a-4cb8-97e0-d4f287a1c971.jpg?w=750&h=&q=100"
            ],
            calendarImageURLs: [
                "https://cdn.newsculture.press/news/photo/202404/546298_687539_5839.jpg",
                "https://img.sportsworldi.com/content/image/2023/06/11/20230611511522.jpg"
            ],
            hotImageURLs: [
                "https://cdn.newsculture.press/news/photo/202404/546298_687539_5839.jpg",
                "https://img.sportsworldi.com/content/image/2023/06/11/20230611511522.jpg"
            ]
        )
    }
}
