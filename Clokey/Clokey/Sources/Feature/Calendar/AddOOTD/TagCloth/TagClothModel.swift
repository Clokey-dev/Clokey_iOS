//
//  TagClothModel.swift
//  Clokey
//
//  Created by 황상환 on 1/31/25.
//

import Foundation
import UIKit

struct TagClothModel {
    let image: UIImage
    let count: Int
    let name: String

    static func getDummyData(for segmentIndex: Int) -> [TagClothModel] {
        let dummyImage = UIImage(named: "test_cloth") ?? UIImage()

        switch segmentIndex {
        case 0: // 전체
            return [
                TagClothModel(image: dummyImage, count: 5, name: "티셔츠"),
                TagClothModel(image: dummyImage, count: 7, name: "니트/스웨터"),
                TagClothModel(image: dummyImage, count: 3, name: "맨투맨"),
                TagClothModel(image: dummyImage, count: 2, name: "후드티"),
                TagClothModel(image: dummyImage, count: 9, name: "청바지"),
                TagClothModel(image: dummyImage, count: 6, name: "반바지"),
                TagClothModel(image: dummyImage, count: 4, name: "트레이닝/조거팬츠"),
                TagClothModel(image: dummyImage, count: 8, name: "가죽자켓"),
                TagClothModel(image: dummyImage, count: 8, name: "1"),
                TagClothModel(image: dummyImage, count: 5, name: "2"),
                TagClothModel(image: dummyImage, count: 2, name: "3")
            ]
        case 1: // 상의
            return [
                TagClothModel(image: dummyImage, count: 5, name: "티셔츠"),
                TagClothModel(image: dummyImage, count: 7, name: "니트/스웨터"),
                TagClothModel(image: dummyImage, count: 3, name: "맨투맨"),
                TagClothModel(image: dummyImage, count: 2, name: "후드티")
            ]
        case 2: // 하의
            return [
                TagClothModel(image: dummyImage, count: 9, name: "청바지"),
                TagClothModel(image: dummyImage, count: 6, name: "반바지"),
                TagClothModel(image: dummyImage, count: 4, name: "트레이닝/조거팬츠")
            ]
        case 3: // 아우터
            return [
                TagClothModel(image: dummyImage, count: 8, name: "가죽자켓"),
                TagClothModel(image: dummyImage, count: 5, name: "패딩"),
                TagClothModel(image: dummyImage, count: 2, name: "점퍼")
            ]
        case 4: // 기타
            return [
                TagClothModel(image: dummyImage, count: 8, name: "1"),
                TagClothModel(image: dummyImage, count: 5, name: "2"),
                TagClothModel(image: dummyImage, count: 2, name: "3")
            ]
        default:
            return []
        }
    }
}
