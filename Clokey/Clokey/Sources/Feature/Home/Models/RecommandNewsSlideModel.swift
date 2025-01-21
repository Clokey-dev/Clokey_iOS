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

extension RecommandNewsSlideModel{
    ///  PickViewController에 들어갈 dummy 데이터 3개를 추가
    static func slideDummyData() -> [RecommandNewsSlideModel] {
        return [
            RecommandNewsSlideModel(image: "recommandNewsSlide1", title: "OO님이 자주 착용하는", hashtag: "#아이템1"),
            RecommandNewsSlideModel(image: "clothes", title: "OO님이 자주 착용하는", hashtag: "#아이템2"),
            RecommandNewsSlideModel(image: "clothes2", title: "OO님이 자주 착용하는", hashtag: "#아이템3")
        ]
    }
}
