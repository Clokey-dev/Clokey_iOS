//
//  RecommandNewsSlideModel.swift
//  Clokey
//
//  Created by 한금준 on 1/12/25.
//

import Foundation

struct RecommandNewsSlideModel {
    let image: String // 이미지 파일 이름 또는 URL
    let title: String
    let hashtag: String
}

extension RecommandNewsSlideModel {
    ///  PickViewController에 들어갈 dummy 데이터 3개를 추가
    static func slideDummyData() -> [RecommandNewsSlideModel] {
        return [
            RecommandNewsSlideModel(image: "https://cdnweb01.wikitree.co.kr/webdata/editor/202404/02/img_20240402160845_51a5022b.webp", title: "OO님이 자주 착용하는", hashtag: "#아이템1"),
            RecommandNewsSlideModel(image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmc4dyj5mmVuZ45PSSayCP_TQ85O-qv7R9Mg&s", title: "OO님이 자주 착용하는", hashtag: "#아이템2"),
            RecommandNewsSlideModel(image: "https://cdn.hankooki.com/news/photo/202310/110067_150612_1697149706.jpg", title: "OO님이 자주 착용하는", hashtag: "#아이템3")
        ]
    }
}
