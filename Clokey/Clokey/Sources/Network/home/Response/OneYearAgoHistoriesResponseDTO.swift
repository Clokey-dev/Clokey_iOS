//
//  OneYearAgoHistoriesResponseDTO.swift
//  Clokey
//
//  Created by 한금준 on 2/2/25.
//

import Foundation

public struct OneYearAgoHistoriesResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: HistoryResult?
}

public struct HistoryResult: Decodable {
    let historyId: Int
    let images: [String]
}
