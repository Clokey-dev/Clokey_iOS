//
//  ReportResponseDTO.swift
//  Clokey
//
//  Created by 한금준 on 3/16/25.
//

import Foundation

// Recap
public struct getProfileReportInformationResponseDTO: Codable {
    let clokeyId: String
    let nickname: String
    let userProfile: String
    let reportTypeResults: [ReportTypeResults]

    struct ReportTypeResults: Codable {
        let reportType: String
        let reportContents: [String]
        let title: String
    }
}

