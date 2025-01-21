//
//  OpenWeatherMap.swift
//  Clokey
//
//  Created by 한금준 on 1/8/25.
//

// 완료

import Foundation

// 전체 응답 구조
struct WeatherResponse: Decodable {
    let resolvedAddress: String    // 요청된 주소
    let days: [DailyWeather]       // 일별 날씨 데이터
}

// 일별 날씨 구조
struct DailyWeather: Decodable {
    let datetime: String           // 날짜 (yyyy-MM-dd 형식)
    let tempmax: Double            // 최고 기온
    let tempmin: Double            // 최저 기온
    let description: String        // 날씨 설명
    let icon: String               // 날씨 아이콘 코드
}

struct WeatherData: Decodable {
    let main: Main
    let name: String
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
}

struct Weather: Decodable {
    let description: String
    let icon: String
}
