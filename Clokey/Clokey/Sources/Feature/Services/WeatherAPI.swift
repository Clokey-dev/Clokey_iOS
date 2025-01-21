//
//  WeatherAPI.swift
//  Clokey
//
//  Created by 한금준 on 1/8/25.
//

import Foundation

class WeatherAPI {
    static let shared = WeatherAPI() // 싱글톤 인스턴스
    
    private let apiKey: String
    private let apiVisualKey: String
    
    private init() {
        guard let openWeatherKey = Bundle.main.object(forInfoDictionaryKey: "OPEN_WEATHER_MAP_KEY") as? String,
              let visualCrossingKey = Bundle.main.object(forInfoDictionaryKey: "VISUAL_CROSSING_WEATHER_KEY") as? String else {
            fatalError("API Keys are missing. Please check your Info.plist.")
        }
        self.apiKey = openWeatherKey
        self.apiVisualKey = visualCrossingKey
    }
    
    func fetchVisualCrossingWeather(for city: String, completion: @escaping (WeatherResponse?) -> Void) {
        let urlString = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(city)?key=\(apiVisualKey)&unitGroup=metric"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching Visual Crossing weather: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(weatherResponse)
            } catch {
                print("Error decoding Visual Crossing weather data: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchWeather(for city: String, completion: @escaping (WeatherData?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric&lang=kr"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                completion(weatherData)
            } catch {
                print("Error decoding weather data: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchTemperatureChange(for city: String, completion: @escaping (String) -> Void) {
        let baseURL = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline"
        let todayURL = "\(baseURL)/\(city)/today?unitGroup=metric&key=\(apiVisualKey)"
        let yesterdayDate = getYesterdayDate()
        let yesterdayURL = "\(baseURL)/\(city)/\(yesterdayDate)?unitGroup=metric&key=\(apiVisualKey)"

        // 두 개의 온도를 비동기적으로 가져오기
        let dispatchGroup = DispatchGroup()

        var currentMinTemp: Double?
        var yesterdayMinTemp: Double?

        // 오늘 최저 온도 가져오기
        dispatchGroup.enter()
        fetchYesterdayVisualCrossingAPI(from: todayURL) { weatherResponse in
            if let weatherResponse = weatherResponse, let todayData = weatherResponse.days.first {
                currentMinTemp = todayData.tempmin
                print("현재 최저 온도: \(currentMinTemp!)°C")
            } else {
                print("현재 최저 온도를 가져오지 못했습니다.")
            }
            dispatchGroup.leave()
        }

        // 어제 최저 온도 가져오기
        dispatchGroup.enter()
        fetchYesterdayVisualCrossingAPI(from: yesterdayURL) { weatherResponse in
            if let weatherResponse = weatherResponse, let yesterdayData = weatherResponse.days.first {
                yesterdayMinTemp = yesterdayData.tempmin
                print("어제 최저 온도: \(yesterdayMinTemp!)°C")
            } else {
                print("어제 최저 온도를 가져오지 못했습니다.")
            }
            dispatchGroup.leave()
        }

        // 모든 데이터가 완료되면 결과 계산
        dispatchGroup.notify(queue: .main) {
            guard let currentMinTemp = currentMinTemp, let yesterdayMinTemp = yesterdayMinTemp else {
                completion("온도 데이터를 가져오지 못했습니다.")
                return
            }

            let temperatureDifference = yesterdayMinTemp - currentMinTemp
            let temperatureDifferenceAbs = abs(temperatureDifference)
            var resultText: String

            if temperatureDifference > 0 {
                resultText = "어제에 비해 기온이 \(Int(temperatureDifferenceAbs))° 떨어졌어요!"
            } else if temperatureDifference < 0 {
                resultText = "어제에 비해 기온이 \(Int(temperatureDifferenceAbs))° 올라갔어요!"
            } else {
                resultText = "현재 최저 기온이 어제 최저 기온과 동일합니다."
            }

            completion(resultText)
        }
    }
    
    // Visual Crossing Weather API 호출 함수
    private func fetchYesterdayVisualCrossingAPI(from url: String, completion: @escaping (WeatherResponse?) -> Void) {
        guard let requestURL = URL(string: url) else {
            print("Invalid Visual Crossing API URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { data, response, error in
            if let error = error {
                print("Error fetching Visual Crossing data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received from Visual Crossing API")
                completion(nil)
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(weatherResponse)
            } catch {
                print("Error decoding Visual Crossing data: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    // 어제의 날짜 계산 (yyyy-MM-dd 형식)
    private func getYesterdayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return formatter.string(from: yesterday)
    }
}
