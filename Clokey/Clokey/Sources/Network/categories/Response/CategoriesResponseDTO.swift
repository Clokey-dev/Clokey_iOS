//
//  CategoriesResponseDTO.swift
//  Clokey
//
//  Created by 한금준 on 2/12/25.
//

import Foundation

public struct CategoriesResponseDTO: Codable {
    public let categoryId: Int64
    public let largeCategoryName: String
    public let smallCategoryName: String
}
