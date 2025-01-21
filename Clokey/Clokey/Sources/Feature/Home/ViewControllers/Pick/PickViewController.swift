//
//  PickViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/8/25.
//

// 완료

import UIKit
import Kingfisher

class PickViewController: UIViewController {
    private let pickView = PickView()
    
    // 더미 데이터 예시
    private let model = PickImageModel(
        weatherImageURLs: [
            "https://img.danawa.com/prod_img/500000/436/224/img/17224436_1.jpg?_v=20220610092752",
            "https://www.ocokorea.com//upload/images/product/111/111888/Product_1670035608378.jpg",
            "https://item.elandrs.com/r/image/item/2023-10-13/fbb4c2ed-930a-4cb8-97e0-d4f287a1c971.jpg?w=750&h=&q=100"
        ],
        recapImageURLs: [
            "https://cdn.newsculture.press/news/photo/202404/546298_687539_5839.jpg",
            "https://img.sportsworldi.com/content/image/2023/06/11/20230611511522.jpg"
        ]
    )
    
    override func loadView() {
        self.view = pickView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true // 현재 컨텍스트에서 새로운 뷰 표시
        
        updateTimeLabel() // 현재 시간 업데이트
        fetchWeatherData() // 날씨 데이터 가져오기
        fetchVisualCrossingWeatherData(for: "Seoul") // 기본 위치: 서울
        updateYesterdayWeatherUI()
        setupBottomLabelTap()
        bindData()
        
    }
    
    private func bindData() {
        // 데이터를 PickView에 바인딩
        pickView.weatherImageView1.kf.setImage(with: URL(string: model.weatherImageURLs[0]))
        pickView.weatherImageView2.kf.setImage(with: URL(string: model.weatherImageURLs[1]))
        pickView.weatherImageView3.kf.setImage(with: URL(string: model.weatherImageURLs[2]))
        
        pickView.recapImageView1.kf.setImage(with: URL(string: model.recapImageURLs[0]))
        pickView.recapImageView2.kf.setImage(with: URL(string: model.recapImageURLs[1]))
    }
    
    // MARK: - 날씨 데이터 요청
    func fetchVisualCrossingWeatherData(for location: String) {
        WeatherAPI.shared.fetchVisualCrossingWeather(for: location) { [weak self] weatherResponse in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let weatherResponse = weatherResponse, let todayWeather = weatherResponse.days.first {
                    self.updateWeatherHighLowUI(weather: todayWeather)
                } else {
                    self.showError()
                }
            }
        }
    }
    
    // MARK: - 날씨 데이터 가져오기
    func fetchWeatherData() {
        WeatherAPI.shared.fetchWeather(for: "Seoul") { [weak self] weatherData in
            DispatchQueue.main.async {
                if let weather = weatherData {
                    self?.updateTemperatureUI(weather: weather)
                }
            }
        }
    }
    
    // MARK: - 시간 업데이트
    func updateTimeLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        pickView.timeLabel.text = formatter.string(from: Date()) + " 대한민국 서울시 기준"
    }
    
    // MARK: - 날씨 아이콘 가져오기
    func fetchWeatherIcon(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather icon: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to load weather icon image")
                return
            }
            
            DispatchQueue.main.async {
                self.pickView.weatherIconView.image = image
            }
        }.resume()
    }
    
    // MARK: - 날씨 데이터 업데이트
    func updateTemperatureUI(weather: WeatherData) {
        pickView.temperatureLabel.text = "\(Int(weather.main.temp))°C"
        
        // 아이콘 가져오기
        if let icon = weather.weather.first?.icon {
            let iconURL = "https://openweathermap.org/img/wn/\(icon)@2x.png"
            fetchWeatherIcon(from: iconURL)
        }
    }
    
    /// 최고/최저 온도 업데이트
    func updateWeatherHighLowUI(weather: DailyWeather) {
        pickView.tempDetailsLabel.text = "최고: \(Int(weather.tempmax))° / 최저: \(Int(weather.tempmin))°"
    }
    
    func updateYesterdayWeatherUI() {
        // WeatherAPI에서 fetchTemperatureChange를 호출하고 결과를 처리
        WeatherAPI.shared.fetchTemperatureChange(for: "Seoul") { [weak self] resultText in
            guard let self = self else { return }

            DispatchQueue.main.async {
                // 결과를 temperatureChangeLabel에 표시
                self.pickView.temperatureChangeLabel.text = resultText
            }
        }
    }
    
    // MARK: - 에러 처리
    func showError() {
        pickView.temperatureLabel.text = "데이터를 가져올 수 없음"
        pickView.tempDetailsLabel.text = "최고/최저 기온 없음"
        pickView.weatherIconView.image = nil
    }
    
    // MARK: - bottomLabel에 TapGestureRecognizer 추가
    private func setupBottomLabelTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBottomLabelTap))
        pickView.bottomButtonLabel.isUserInteractionEnabled = true
        pickView.bottomButtonLabel.addGestureRecognizer(tapGesture)
    }
    @objc private func handleBottomLabelTap() {
        // ClosetViewController가 포함된 탭의 index를 설정하세요.
        guard let tabBarController = self.tabBarController else {
            print("TabBarController가 없습니다.")
            return
        }
        
        // ClosetViewController가 포함된 탭의 index (예: 2번째 탭이라면 index는 1)
        tabBarController.selectedIndex = 1 // ClosetViewController가 연결된 탭 index로 변경
    }
}
