//
//  WeatherExample.swift
//  Clokey
//
//  Created by 한금준 on 6/24/25.
//

import UIKit
import WeatherKit
import CoreLocation


final class PickViewController: UIViewController, CLLocationManagerDelegate {
    private var timeUpdateTimer: Timer?
    private var backgroundView: UIView?// 배경 어둡게 하기 위해 선언
    
    var latitude : Double = 0
    var longitude : Double = 0
    
    var nowTemp: Int?
    var maxTemp: Int?
    var minTemp: Int?
    
    private var recapHistoryId1: Int?
    private var recapHistoryId2: Int?
    
    // 팝업 뷰
    private let popUpView = PickPopUpView()
    private let pickView = PickView()

    let weatherService = WeatherService.shared
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    
    private let model = PickImageModel.dummy()
    //새로고침 기능 추가
    private let refreshControl = UIRefreshControl()
    private var isDataLoaded: Bool = false // 데이터 로드 여부 플래그
    private var loadingOverlay: UIView?
    
    var dateString : String = ""
    var month: String = ""
    var date : String = ""
    
    var clothId1:Int64?
    var clothId2:Int64?
    var clothId3:Int64?
    
    var url: String = ""
    
    // address 값을 저장할 변수
    private var address: String = "" // 기본값 설정
    
    private var englishAddress: String = ""
    
    func dateFormatter() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MM"
            let month = formatter.string(from: date)
            self.month = String(Int(month) ?? 0)
            print(month)
        }
    }
    
    func isOneYearAgo(dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC") // 서버 시간이 UTC일 경우

        guard let date = formatter.date(from: dateString) else {
            print("날짜 변환 실패")
            return false
        }

        let calendar = Calendar.current
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date()) else {
            print("1년 전 날짜 계산 실패")
            return false
        }

        return calendar.isDate(date, inSameDayAs: oneYearAgo)
    }

    override func loadView() {
        self.view = pickView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true // 현재 컨텍스트에서 새로운 뷰 표시
        // 새로고침 기능 추가
        pickView.scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        
        setupActions()

        startPreciseMinuteTimer()
        setupBottomLabelTap()
        
        if isDataLoaded {
            if loadingOverlay != nil {
                hideLoadingOverlay()
            }
        } else {
            // 데이터가 로드되지 않았고, 오버레이가 아직 없다면 오버레이 표시
            if loadingOverlay == nil {
                showLoadingOverlay()
            }
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleHideLoadingOverlay),
                                               name: NSNotification.Name("HideLoadingOverlayNotification"),
                                               object: nil)
        
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setupLocationIconTap()
        loadRecapData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.pickView.recapImageView1.image = nil
        self.pickView.recapImageView2.image = nil
        loadRecapData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupActions() {
        popUpView.deleteButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        pickView.weatherImageView1.isUserInteractionEnabled = true
        pickView.weatherImageView1.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        pickView.weatherImageView2.isUserInteractionEnabled = true
        pickView.weatherImageView2.addGestureRecognizer(tapGesture2)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        pickView.weatherImageView3.isUserInteractionEnabled = true
        pickView.weatherImageView3.addGestureRecognizer(tapGesture3)
        
        // Recap 이미지 탭 제스처 추가
        let recapTapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleRecapImageTap(_:)))
        pickView.recapImageView1.isUserInteractionEnabled = true
        pickView.recapImageView1.addGestureRecognizer(recapTapGesture1)
        
        let recapTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleRecapImageTap(_:)))
        pickView.recapImageView2.isUserInteractionEnabled = true
        pickView.recapImageView2.addGestureRecognizer(recapTapGesture2)
    }
    
    private func fetchHistoryDetail(historyId: Int) {
        let historyService = HistoryService()
        
        historyService.historyDetail(historyId: historyId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("히스토리 상세 조회 성공: \(response)")
                
                DispatchQueue.main.async {
                    let detailVC = FriendsCalendarDetailViewController()
                    detailVC.setDetailData(response)
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            case .failure(let error):
                print("히스토리 상세 조회 실패: \(error.localizedDescription)")
                self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
            }
        }
    }
    
    // 팝업 닫기 함수
    @objc private func dismissPopup() {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first })
            .first else { return }
        
        //  keyWindow에서 PopUpView 찾기
        if let popUpView = keyWindow.subviews.first(where: { $0 is PickPopUpView }) {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView?.alpha = 0 // 배경도 함께 사라지게 함
                popUpView.alpha = 0
            }) { _ in
                self.backgroundView?.removeFromSuperview() // 배경 제거
                popUpView.removeFromSuperview()
                self.backgroundView = nil // 참조 해제
            }
        }
    }
    
    @objc private func handleRecapImageTap(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        
        var historyId: Int?
        
        if tappedImageView == pickView.recapImageView1 {
            historyId = recapHistoryId1
        } else if tappedImageView == pickView.recapImageView2 {
            historyId = recapHistoryId2
        }
        
        if let id = historyId {
            fetchHistoryDetail(historyId: id)
        }
    }
    
    @objc private func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        
        var selectedClothId: Int64?
        
        if tappedImageView == pickView.weatherImageView1 {
            selectedClothId = clothId1
        } else if tappedImageView == pickView.weatherImageView2 {
            selectedClothId = clothId2
        } else if tappedImageView == pickView.weatherImageView3 {
            selectedClothId = clothId3
        }
        
        guard let clothId = selectedClothId else {
            print("clothId 값이 없습니다.")
            return
        }
        
        
        showPopup(with: tappedImageView.image, clothId: clothId)
        
    }
    
    private func showPopup(with image: UIImage?, clothId: Int64) {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first })
            .first else { return } // keyWindow 설정
        
        // 뒷 배경 어둡게
        let bgView = UIView()
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        bgView.alpha = 0
        keyWindow.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundView = bgView
        
        // 팝업 뷰 생성
        self.popUpView.alpha = 0
        self.popUpView.setImage(image)
        keyWindow.addSubview(self.popUpView)

        self.popUpView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(290)
            make.height.equalTo(489)
        }
        
        // 팝업 애니메이션 효과
        UIView.animate(withDuration: 0.3) {
            bgView.alpha = 1
            self.popUpView.alpha = 1
        }
        
        // closeButton 클릭 시 팝업 닫기 기능 추가
        popUpView.deleteButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        bgView.addGestureRecognizer(tap)
        
        let clotehsService = ClothesService()
        
        // checkPopUpClothes API 호출 및 UI 업데이트
        clotehsService.checkPopUpClothes(clothId: clothId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // 응답 데이터를 popUpView에 반영
                    self.popUpView.nameLabel.text = response.name
                    if let imageUrl = URL(string: response.imageUrl) {
                        self.popUpView.imageView.kf.setImage(with: imageUrl)
                    } else {
                        print("유효하지 않은 이미지 URL: \(response.imageUrl)")
                    }
                    if response.visibility == "PUBLIC" {
                        self.popUpView.publicButton.setImage(UIImage(named: "public_icon"), for: .normal)
                    } else {
                        self.popUpView.publicButton.setImage(UIImage(named: "lock_on"), for: .normal)
                    }
                    
                    
                    self.popUpView.categoryButton2.setTitle("\(response.category)", for: .normal)
                    print(response.category)
                    
                    if let categoryName = CategoryModel.getCategoryNameByClothName(response.category) {
                        print(categoryName) // 출력: "상의"
                        self.popUpView.categoryButton1.setTitle("\(categoryName)", for: .normal)
                    }
                    
                    if response.seasons.count > 0 {
                        if response.seasons[0] == "SPRING" {
                            self.popUpView.springButton.setTitleColor(.white, for: .normal)
                            self.popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.springButton.layer.cornerRadius = 5
                            self.popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "SUMMER" {
                            self.popUpView.summerButton.setTitleColor(.white, for: .normal)
                            self.popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.summerButton.layer.cornerRadius = 5
                            self.popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "FALL" {
                            self.popUpView.fallButton.setTitleColor(.white, for: .normal)
                            self.popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.fallButton.layer.cornerRadius = 5
                            self.popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "WINTER" {
                            self.popUpView.winterButton.setTitleColor(.white, for: .normal)
                            self.popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.winterButton.layer.cornerRadius = 5
                            self.popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 1 {
                        if response.seasons[1] == "SPRING" {
                            self.popUpView.springButton.setTitleColor(.white, for: .normal)
                            self.popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.springButton.layer.cornerRadius = 5
                            self.popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "SUMMER" {
                            self.popUpView.summerButton.setTitleColor(.white, for: .normal)
                            self.popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.summerButton.layer.cornerRadius = 5
                            self.popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "FALL" {
                            self.popUpView.fallButton.setTitleColor(.white, for: .normal)
                            self.popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.fallButton.layer.cornerRadius = 5
                            self.popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "WINTER" {
                            self.popUpView.winterButton.setTitleColor(.white, for: .normal)
                            self.popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.winterButton.layer.cornerRadius = 5
                            self.popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 2 {
                        if response.seasons[2] == "SPRING" {
                            self.popUpView.springButton.setTitleColor(.white, for: .normal)
                            self.popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.springButton.layer.cornerRadius = 5
                            self.popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "SUMMER" {
                            self.popUpView.summerButton.setTitleColor(.white, for: .normal)
                            self.popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.summerButton.layer.cornerRadius = 5
                            self.popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "FALL" {
                            self.popUpView.fallButton.setTitleColor(.white, for: .normal)
                            self.popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.fallButton.layer.cornerRadius = 5
                            self.popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "WINTER" {
                            self.popUpView.winterButton.setTitleColor(.white, for: .normal)
                            self.popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.winterButton.layer.cornerRadius = 5
                            self.popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 3 {
                        if response.seasons[3] == "SPRING" {
                            self.popUpView.springButton.setTitleColor(.white, for: .normal)
                            self.popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.springButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.springButton.layer.cornerRadius = 5
                            self.popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "SUMMER" {
                            self.popUpView.summerButton.setTitleColor(.white, for: .normal)
                            self.popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.summerButton.layer.cornerRadius = 5
                            self.popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "FALL" {
                            self.popUpView.fallButton.setTitleColor(.white, for: .normal)
                            self.popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.fallButton.layer.cornerRadius = 5
                            self.popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "WINTER" {
                            self.popUpView.winterButton.setTitleColor(.white, for: .normal)
                            self.popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            self.popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
                            self.popUpView.winterButton.layer.cornerRadius = 5
                            self.popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    self.popUpView.wearCountButton.setTitle("\(response.wearNum)회", for: .normal)
                    self.popUpView.brandNameLabel.text = (response.brand?.isEmpty ?? true) ? "없음" : response.brand
                    self.updateUrlGoButtonTitle(with: response.clothUrl)

                    // 이미지가 있으면 업데이트
                    if let imageUrl = URL(string: response.imageUrl) {
                        self.popUpView.imageView.kf.setImage(with: imageUrl)
                    }
                    
                    self.popUpView.urlGoButton.addTarget(self, action: #selector(self.urlGoButtonTapped), for: .touchUpInside)
                    
                case .failure(let error):
                    print("팝업 의류 데이터 로드 실패: \(error.localizedDescription)")
                    self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
                }
            }
        }
    }

    @objc private func urlGoButtonTapped() {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        // URL 열기
        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                print("Opened URL: \(url)")
            } else {
                print("Failed to open URL: \(url)")
            }
        }
    }
    
    func updateUrlGoButtonTitle(with url: String?) {
        let title = (url?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false) ? "없음" : "바로가기"
        
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.mainBrown800,
            .font: UIFont.ptdMediumFont(ofSize: 12)
        ]

        if title != "없음" {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        popUpView.urlGoButton.setAttributedTitle(attributedTitle, for: .normal)
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }


    private func fetchWeather(for location: CLLocation) {
        _Concurrency.Task {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date()) // 수정: 오늘 날짜를 00:00 기준으로 고정
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return }

            do {
                // 위치 이름 가져오기
                let geocoder = CLGeocoder()
                let placemarks = try await geocoder.reverseGeocodeLocation(location)

                let locationName = placemarks.first.map { placemark in
                    [placemark.locality, placemark.subLocality, placemark.name]
                        .compactMap { $0 }
                        .joined(separator: " ")
                } ?? "알 수 없는 위치"

                
                // 현재 날씨
                let current = try await weatherService.weather(for: location, including: .current)
                let currentTemp = current.temperature.value
                let currentDesc = current.condition.description
                let symbolName = current.symbolName
                
                let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
                let iconImage = UIImage(systemName: symbolName, withConfiguration: config)?
                    .withRenderingMode(.alwaysTemplate)

                // 어제와 오늘의 일별 예보
                let startDate = calendar.startOfDay(for: yesterday)
                let endDate = calendar.startOfDay(for: tomorrow)
                let daily = try await weatherService.weather(for: location, including: .daily(startDate: startDate, endDate: endDate))

                var yesterdayLow: Double?
                var todayHigh: Double?
                var todayLow: Double?

                for day in daily.forecast {

                    if calendar.isDate(day.date, inSameDayAs: yesterday) {
                        yesterdayLow = day.lowTemperature.value
                    } else if calendar.isDate(day.date, inSameDayAs: today) {
                        todayHigh = day.highTemperature.value
                        todayLow = day.lowTemperature.value
                    }
                }
                
                // Fallback: 오늘의 일별 레코드가 아직 없으면 시간별 예보로 최고/최저 계산
                if todayHigh == nil || todayLow == nil {
                    let hourly = try await weatherService.weather(
                        for: location,
                        including: .hourly(startDate: today, endDate: tomorrow)
                    )
                    
                    var maxTemp: Double = -Double.greatestFiniteMagnitude
                    var minTemp: Double =  Double.greatestFiniteMagnitude
                    
                    for hour in hourly.forecast where calendar.isDate(hour.date, inSameDayAs: today) {
                        let temp = hour.temperature.value
                        maxTemp = max(maxTemp, temp)
                        minTemp = min(minTemp, temp)
                    }
                    
                    if maxTemp != -Double.greatestFiniteMagnitude,
                       minTemp != Double.greatestFiniteMagnitude {
                        todayHigh = maxTemp
                        todayLow  = minTemp
                    }
                }

                // 결과 출력
                var tempDetail = ""
                var maxTemp: Int32 = 0
                var minTemp: Int32 = 0
                var resultText = ""
                var yesterdayL: Int32 = 0
                
                
                if let yLow = yesterdayLow {
                    yesterdayL = Int32(yLow)
                }
                if let tHigh = todayHigh, let tLow = todayLow {
                    tempDetail += " (최고: \(Int(tHigh))° / 최저: \(Int(tLow))°)"
                    maxTemp = Int32(tHigh)
                    minTemp = Int32(tLow)
                }
                
                let temperatureDifference = yesterdayL - minTemp
                let temperatureDifferenceAbs = abs(temperatureDifference)
                
                if temperatureDifference > 0 {
                    resultText = "어제에 비해 기온이 \(Int(temperatureDifferenceAbs))° 떨어졌어요!"
                } else if temperatureDifference < 0 {
                    resultText = "어제에 비해 기온이 \(Int(temperatureDifferenceAbs))° 올라갔어요!"
                } else {
                    resultText = "현재 최저 기온이 어제 최저 기온과 동일합니다."
                }

                await MainActor.run {
                    self.pickView.temperatureLabel.text = "\(Int32(currentTemp))°C"
                    self.pickView.tempDetailsLabel.text = tempDetail
                    self.pickView.temperatureChangeLabel.text = resultText
                    fetchWeatherRecommendations(nowTemp: Int32(currentTemp), maxTemp: maxTemp, minTemp: minTemp)
                    
                    self.pickView.weatherIconView.tintColor = UIColor.mainBrown800
                    self.pickView.weatherIconView.image = iconImage
                }

            } catch {
                await MainActor.run {
                    showError()
                }
            }
        }
    }
    
    func fetchWeatherRecommendations(nowTemp: Int32?, maxTemp: Int32?, minTemp: Int32?) {
        
        guard let nowTemp = nowTemp,
              let maxTemp = maxTemp,
              let minTemp = minTemp else {
            print("오류: 온도 값이 없습니다.")
            return
        }
        let nowTemp32 = Int32(nowTemp)
        let maxTemp32 = Int32(maxTemp)
        let minTemp32 = Int32(minTemp)
        
        let homeService = HomeService()
        
        homeService.recommendClothes(nowTemp: nowTemp32, minTemp: minTemp32, maxTemp: maxTemp32) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    
                    let recommendedClothes = response.recommendations
                    
                    self.pickView.updateEmptyState(isEmpty: response.recommendations.isEmpty)
                    
                    
                    self.pickView.weatherImageView2.isHidden = recommendedClothes.isEmpty || recommendedClothes.count < 2
                    self.pickView.weatherImageName2.isHidden = recommendedClothes.isEmpty || recommendedClothes.count < 2
                    
                    self.pickView.weatherImageView3.isHidden = recommendedClothes.isEmpty || recommendedClothes.count < 3
                    self.pickView.weatherImageName3.isHidden = recommendedClothes.isEmpty || recommendedClothes.count < 3
                    
                    // 이미지 설정 (최대 3개)
                    if recommendedClothes.count > 0 {
                        self.pickView.weatherImageView1.kf.setImage(with: URL(string: recommendedClothes[0].imageUrl))
                        self.pickView.weatherImageName1.text = recommendedClothes[0].clothName
                        self.clothId1 = recommendedClothes[0].clothId
                    }
                    if recommendedClothes.count > 1 {
                        self.pickView.weatherImageView2.kf.setImage(with: URL(string: recommendedClothes[1].imageUrl))
                        self.pickView.weatherImageName2.text = recommendedClothes[1].clothName
                        self.clothId2 = recommendedClothes[1].clothId
                    }
                    if recommendedClothes.count > 2 {
                        self.pickView.weatherImageView3.kf.setImage(with: URL(string: recommendedClothes[2].imageUrl))
                        self.pickView.weatherImageName3.text = recommendedClothes[2].clothName
                        self.clothId3 = recommendedClothes[2].clothId
                    }
                    self.hideLoadingOverlay()
                    self.isDataLoaded = true // 데이터 로드 완료
                case .failure(let error):
                    print("추천 의상 데이터 가져오기 실패: \(error.localizedDescription)")
                    self.pickView.updateEmptyState(isEmpty: true)
                    self.hideLoadingOverlay()
                    self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
                }
            }
        }
    }
    
    // MARK: - 시간 업데이트
    func updateTimeLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let currentTime = formatter.string(from: Date())
        pickView.timeLabel.text = "\(currentTime) 대한민국 \(address) 기준"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if let location = locations.first {
                    userLocation = location
                    fetchWeather(for: location)
                }
        
        // 한 번만 업데이트를 받도록 중단
        locationManager.stopUpdatingLocation()
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
        
        // 좌표 값 추출
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let geocoderEnglish = CLGeocoder()
        // (옵션) 주소 업데이트를 위해 reverse geocoding 수행
        geocoderEnglish.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.first {
                var subAddress = ""
                if let administrativeArea = placemark.administrativeArea {
                    subAddress += administrativeArea
                }
                if let locality = placemark.locality {
                    subAddress += " " + locality
                }
                DispatchQueue.main.async {
                    self.englishAddress = subAddress
                    self.updateTimeLabel()
                    self.latitude = latitude
                    self.longitude = longitude
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
    
    // MARK: - 에러 처리
    func showError() {
        pickView.temperatureLabel.text = "데이터를 가져오는 중입니다."
        pickView.tempDetailsLabel.text = "최고/최저 기온을 가져오는 중입니다."
        pickView.weatherIconView.image = nil
    }
    
    private func setupBottomLabelTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBottomLabelTap))
        pickView.bottomButtonLabel.isUserInteractionEnabled = true
        pickView.bottomButtonLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleBottomLabelTap() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.navigateToMyCloset()
        }
    }
    
    // Recap 데이터를 로드하고 PickView에 전달
    private func loadRecapData() {
        let homeService = HomeService()
        
        homeService.fetchOneYearAgoHistories { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let historyResult):
                    let imageUrls = historyResult.imageUrls
                    let nickName = historyResult.nickName
                    let historyId = historyResult.historyId
                    self.dateString = historyResult.date ?? ""
                    self.dateFormatter()
                    
                    if imageUrls.count > 0 {
                        self.recapHistoryId1 = Int(historyId!) // 첫 번째 이미지에 대한 historyId
                        // 두 번째 이미지는 같은 historyId를 사용하거나 필요에 따라 다르게 처리
                        if imageUrls.count > 1 {
                            self.recapHistoryId2 = Int(historyId!) // 두 번째 이미지에 대한 historyId
                        }
                    }
                    
                    if self.isOneYearAgo(dateString: self.dateString) {
                        if let isMine = historyResult.isMine {
                            if isMine {
                                // isMine == true
                                if imageUrls.isEmpty {
                                    print("사진이 없습니다")
                                } else {
                                    self.pickView.recapSubtitleLabel1.text = "1년 전 오늘, \(nickName)님은 이 옷을 착용하셨네요!"
                                    self.pickView.recapNotMe(hidden: true)
                                    
                                    if imageUrls.count > 0 {
                                        self.pickView.recapImageView1.kf.setImage(with: URL(string: imageUrls[0]))
                                        if imageUrls.count > 1 {
                                            self.pickView.recapImageView2.kf.setImage(with: URL(string: imageUrls[1]))
                                        }
                                    }
                                    
                                }
                            } else {
                                // isMine == false
                                if imageUrls.isEmpty {
                                    print("사진이 없습니다")
                                } else {
                                    self.pickView.recapSubtitleLabel1.text = "1년 전 오늘의 기록이 없어요!"
                                    self.pickView.recapNotMe(hidden: false)
                                    self.pickView.recapSubtitleLabel2.text = "\(nickName)님의 1년 전 오늘을 확인해보세요!"
                                    if imageUrls.count > 0 {
                                        self.pickView.recapImageView1.kf.setImage(with: URL(string: imageUrls[0]))
                                        if imageUrls.count > 1 {
                                            self.pickView.recapImageView2.kf.setImage(with: URL(string: imageUrls[1]))
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // historyResult.isMine == nil 일 때 처리
                        self.pickView.recapSubtitleLabel1.text = "1년 전 오늘의 기록이 없어요!"
                        self.pickView.recapNotMe(hidden: false)
                        self.pickView.recapSubtitleLabel2.text = "\(nickName)님의 \(self.month)월의 기록을 확인해보세요."
                        
                        
                        if imageUrls.count > 0 {
                            self.pickView.recapImageView1.kf.setImage(with: URL(string: imageUrls[0]))
                            if imageUrls.count > 1 {
                                self.pickView.recapImageView2.kf.setImage(with: URL(string: imageUrls[1]))
                            }
                        }
                    }
                case .failure(let error):
                    print("데이터 로드 실패: \(error.localizedDescription)")
                    self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
                }
            }
        }
    }
    
    //새로고침 함수
    @objc private func didPullToRefresh() {
        // 필요에 따라 여러 API 호출을 재실행합니다.
        
        self.pickView.recapImageView1.image = nil
        self.pickView.recapImageView2.image = nil
        loadRecapData()
        
        // 약간의 지연 후 refreshControl 종료
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func showLoadingOverlay() {
        let overlay = UIView()
        overlay.backgroundColor = .white
        view.addSubview(overlay)
        
        // SnapKit을 사용하여 전체화면 제약조건 추가
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingOverlay = overlay
    }
    
    private func hideLoadingOverlay() {
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingOverlay?.alpha = 0
        }) { _ in
            self.loadingOverlay?.removeFromSuperview()
            self.loadingOverlay = nil
        }
    }
    
    @objc private func handleHideLoadingOverlay() {
        print("HideLoadingOverlayNotification received")
        // 데이터 로드가 완료된 상태로 간주
        isDataLoaded = true
        hideLoadingOverlay()
    }
    
    func startPreciseMinuteTimer() {
        let calendar = Calendar.current
        let now = Date()
        
        // 다음 정각 (초단위 0)까지 남은 시간 계산
        let nextMinute = calendar.nextDate(after: now, matching: DateComponents(second: 0), matchingPolicy: .nextTime)!
        let delay = nextMinute.timeIntervalSince(now)
        
        // 정각까지 한 번 딜레이 후, 60초 간격 타이머 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.updateTimeLabel()
            self?.timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
                self?.updateTimeLabel()
            }
        }
    }
    
    deinit {
        timeUpdateTimer?.invalidate()
    }
}
