//
//  PickViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/8/25.
//

// 완료

import UIKit
import Kingfisher
import MapKit

class PickViewController: UIViewController, CLLocationManagerDelegate {
    private let pickView = PickView()
    
    let locationManager = CLLocationManager()
    
    private let model = PickImageModel.dummy()
    
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
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setupLocationIconTap()
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
        //        pickView.timeLabel.text = formatter.string(from: Date()) + " 대한민국 서울시 기준"
        let currentTime = formatter.string(from: Date())
        pickView.timeLabel.text = "\(currentTime) 대한민국 \(address) 기준"
    }
    
    // address 값을 저장할 변수
    private var address: String = "" // 기본값 설정
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                var subAddress = ""
                
                if let administrativeArea = placemark.administrativeArea {
                    // "서울특별시"를 "서울시"로 변환
                    if administrativeArea.contains("특별시") {
                        subAddress += administrativeArea.replacingOccurrences(of: "특별시", with: "시")
                    } else if administrativeArea.contains("광역시") {
                        subAddress += administrativeArea.replacingOccurrences(of: "광역시", with: "시")
                    } else if administrativeArea.contains("특별자치도") {
                        subAddress += administrativeArea.replacingOccurrences(of: "특별자치도", with: "도")
                    }
                    else {
                        subAddress += administrativeArea
                        if let locality = placemark.locality {
                            subAddress += " \(locality) "
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.address = subAddress
                    self.updateTimeLabel() // 주소 업데이트 후 시간 레이블 갱신
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    private func setupLocationIconTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLocationIconTap))
        pickView.locationIconView.isUserInteractionEnabled = true
        pickView.locationIconView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleLocationIconTap() {
        print("locationIconView tapped")
        
        // 권한 상태 확인
        let authorizationStatus = locationManager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            // 위치 권한 요청
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // 설정 앱으로 이동하여 권한 요청
            let alert = UIAlertController(
                title: "위치 권한 필요",
                message: "앱에서 위치 정보를 사용하려면 설정에서 권한을 허용해주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler: { _ in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL)
                }
            }))
            present(alert, animated: true)
        case .authorizedWhenInUse, .authorizedAlways:
            // 위치 업데이트 시작
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
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
        pickView.tempDetailsLabel.text = " (최고: \(Int(weather.tempmax))° / 최저: \(Int(weather.tempmin))°)"
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
    private func setupBottomLabelTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBottomLabelTap))
        pickView.bottomButtonLabel.isUserInteractionEnabled = true
        pickView.bottomButtonLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleBottomLabelTap() {
        // Create an instance of the destination view controller
        let closetViewController = ClosetViewController()
        closetViewController.modalPresentationStyle = .fullScreen // Present it as a full-screen modal
        
        // Navigate without keeping the TabBar
        self.present(closetViewController, animated: true, completion: nil)
    }
}


