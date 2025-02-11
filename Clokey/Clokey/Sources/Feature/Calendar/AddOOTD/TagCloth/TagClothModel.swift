//
//  TagClothModel.swift
//  Clokey
//
//  Created by 황상환 on 1/31/25.
//

import Foundation
import UIKit

struct TagClothModel: Equatable {
    let id: Int
    let image: String
    let count: Int
    let name: String
    
    static func == (lhs: TagClothModel, rhs: TagClothModel) -> Bool {
        return lhs.id == rhs.id  // id로 비교
    }
}
