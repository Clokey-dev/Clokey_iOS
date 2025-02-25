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
import Moya

class PickViewController: UIViewController, CLLocationManagerDelegate {
    
    private var backgroundView: UIView?// 배경 어둡게 하기 위해 선언
    
    var nowTemp: Int?
    var maxTemp: Int?
    var minTemp: Int?
    
    private var recapHistoryId1: Int?
    private var recapHistoryId2: Int?
    
    // 팝업 뷰
    private let popUpView = PickPopUpView()
    private let pickView = PickView()
    
    let locationManager = CLLocationManager()
    
    private let model = PickImageModel.dummy()
    //새로고침 기능 추가
    private let refreshControl = UIRefreshControl()
    private var loadingOverlay: UIView?
    
    override func loadView() {
        self.view = pickView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true // 현재 컨텍스트에서 새로운 뷰 표시
        // 새로고침 기능 추가 
        pickView.scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(didPullToRefresh), name: NSNotification.Name("RefreshHomeNotification"), object: nil)
        
        
        setupActions()
        
        updateTimeLabel() // 현재 시간 업데이트
        fetchWeatherData() // 날씨 데이터 가져오기
        fetchVisualCrossingWeatherData(for: "Seoul") // 기본 위치: 서울
        updateYesterdayWeatherUI()
        setupBottomLabelTap()
        //        bindData()
        
        showLoadingOverlay()
        
        
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    var clothId1:Int64?
    var clothId2:Int64?
    var clothId3:Int64?
    
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
            print("❌ clothId 값이 없습니다.")
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
        let popUpView = PickPopUpView()
        popUpView.alpha = 0
        popUpView.setImage(image)
        keyWindow.addSubview(popUpView)
        
        popUpView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(290)
            make.height.equalTo(448)
        }
        
        // 팝업 애니메이션 효과
        UIView.animate(withDuration: 0.3) {
            bgView.alpha = 1
            popUpView.alpha = 1
        }
        
        // closeButton 클릭 시 팝업 닫기 기능 추가
        popUpView.deleteButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        bgView.addGestureRecognizer(tap)
        
        let clotehsService = ClothesService()
        
        // ✅ checkPopUpClothes API 호출 및 UI 업데이트
        clotehsService.checkPopUpClothes(clothId: clothId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // 응답 데이터를 popUpView에 반영
                    popUpView.nameLabel.text = response.name
                    if let imageUrl = URL(string: response.imageUrl) {
                        popUpView.imageView.kf.setImage(with: imageUrl)
                    } else {
                        print("유효하지 않은 이미지 URL: \(response.imageUrl)")
                    }
                    if response.visibility == "PUBLIC" {
                        popUpView.publicButton.setImage(UIImage(named: "lock_off"), for: .normal)
                    } else {
                        popUpView.publicButton.setImage(UIImage(named: "lock_on"), for: .normal)
                    }
                    
                    
                    popUpView.categoryButton2.setTitle("\(response.category)", for: .normal)
                    print(response.category)
                    
                    if let categoryName = CategoryModel.getCategoryNameByClothName(response.category) {
                        print(categoryName) // 출력: "상의"
                        popUpView.categoryButton1.setTitle("\(categoryName)", for: .normal)
                    }
                    
                    if response.seasons.count > 0 {
                        if response.seasons[0] == "SPRING" {
                            //                                configureButton(popUpView.springButton, title: "봄")
                            popUpView.springButton.setTitleColor(.white, for: .normal)
                            popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[0] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 1 {
                        if response.seasons[1] == "SPRING" {
                            //                                configureButton(popUpView.springButton, title: "봄")
                            popUpView.springButton.setTitleColor(.white, for: .normal)
                            popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[1] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 2 {
                        if response.seasons[2] == "SPRING" {
                            //                                configureButton(popUpView.springButton, title: "봄")
                            popUpView.springButton.setTitleColor(.white, for: .normal)
                            popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[2] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
                    if response.seasons.count > 3 {
                        if response.seasons[3] == "SPRING" {
                            //                                configureButton(popUpView.springButton, title: "봄")
                            popUpView.springButton.setTitleColor(.white, for: .normal)
                            popUpView.springButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.springButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.springButton.layer.cornerRadius = 5
                            popUpView.springButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "SUMMER" {
                            //                                configureButton(popUpView.summerButton, title: "여름")
                            popUpView.summerButton.setTitleColor(.white, for: .normal)
                            popUpView.summerButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.summerButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.summerButton.layer.cornerRadius = 5
                            popUpView.summerButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "FALL" {
                            //                                configureButton(popUpView.fallButton, title: "가을")
                            popUpView.fallButton.setTitleColor(.white, for: .normal)
                            popUpView.fallButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.fallButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.fallButton.layer.cornerRadius = 5
                            popUpView.fallButton.layer.borderWidth = 1
                        } else if response.seasons[3] == "WINTER" {
                            //                                configureButton(popUpView.winterButton, title: "겨울")
                            popUpView.winterButton.setTitleColor(.white, for: .normal)
                            popUpView.winterButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
                            popUpView.winterButton.backgroundColor = UIColor(named: "mainBrown600")
                            popUpView.winterButton.layer.cornerRadius = 5
                            popUpView.winterButton.layer.borderWidth = 1
                        }
                    }
                    
//                    popUpView.wearCountButton.titleLabel?.text = "\(response.wearNum)"
                    popUpView.wearCountButton.setTitle("\(response.wearNum)회", for: .normal)
                    popUpView.brandNameLabel.text = (response.brand?.isEmpty ?? true) ? "지정 없음" : response.brand
                    self.url = response.clothUrl ?? ""
                    if response.clothUrl == nil {
                        popUpView.urlGoButton.titleLabel?.text = "지정 안됨"
                    }
                    
                    
                    
                    // 이미지가 있으면 업데이트
                    if let imageUrl = URL(string: response.imageUrl) {
                        popUpView.imageView.kf.setImage(with: imageUrl)
                    }
                    
                    popUpView.urlGoButton.addTarget(self, action: #selector(self.urlGoButtonTapped), for: .touchUpInside)
                    
                case .failure(let error):
                    print("팝업 의류 데이터 로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var url: String = ""
    
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
    

    func fetchWeatherRecommendations() {
        
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
                    
                case .failure(let error):
                    print("추천 의상 데이터 가져오기 실패: \(error.localizedDescription)")
                    self.pickView.updateEmptyState(isEmpty: true)
                    self.hideLoadingOverlay()
                }
            }
        }
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
        
        nowTemp = Int(weather.main.temp)
        
        // 아이콘 가져오기
        if let icon = weather.weather.first?.icon {
            let iconURL = "https://openweathermap.org/img/wn/\(icon)@2x.png"
            fetchWeatherIcon(from: iconURL)
        }
    }
    
    
    
    
    /// 최고/최저 온도 업데이트
    func updateWeatherHighLowUI(weather: DailyWeather) {
        pickView.tempDetailsLabel.text = " (최고: \(Int(weather.tempmax))° / 최저: \(Int(weather.tempmin))°)"
        
        maxTemp = Int(weather.tempmax)
        minTemp = Int(weather.tempmin)
        
        fetchWeatherRecommendations()
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
                    
                    if imageUrls.count > 0 {
                        self.recapHistoryId1 = Int(historyId!) // 첫 번째 이미지에 대한 historyId
                    }
                    // 두 번째 이미지는 같은 historyId를 사용하거나 필요에 따라 다르게 처리
                    if imageUrls.count > 1 {
                        self.recapHistoryId2 = Int(historyId!) // 두 번째 이미지에 대한 historyId
                    }
                    
                    if historyResult.isMine {
                        if imageUrls.isEmpty {
                            print("사진이 없습니다")
                            self.pickView.recapSubtitleLabel1.text = "1년 전 오늘, \(nickName)님의 기록이 없어요!"
                            self.pickView.recapNotMe(hidden: false)
                            self.pickView.recapSubtitleLabel2.text = "1년 전 오늘, 다른 사용자들의 기록도 없어요!"
                        } else {
                            self.pickView.recapSubtitleLabel1.text = "1년 전 오늘, \(nickName)님은 이 옷을 착용하셨네요!"
                            self.pickView.recapNotMe(hidden: true)
                            
                            if imageUrls.count > 0 {
                                self.pickView.recapImageView1.kf.setImage(with: URL(string: imageUrls[0]))
                            }
                            if imageUrls.count > 1 {
                                self.pickView.recapImageView2.kf.setImage(with: URL(string: imageUrls[1]))
                            }
                        }
                    } else {
                        self.pickView.recapSubtitleLabel1.text = "1년 전 오늘의 기록이 없어요!"
                        self.pickView.recapNotMe(hidden: false)
                        self.pickView.recapSubtitleLabel2.text = "\(nickName)님의 1년 전 오늘을 확인해보세요!"
                        
                        if imageUrls.isEmpty {
                            print("📷 사진이 없습니다")
                        } else {
                            if imageUrls.count > 0 {
                                self.pickView.recapImageView1.kf.setImage(with: URL(string: imageUrls[0]))
                            }
                            if imageUrls.count > 1 {
                                self.pickView.recapImageView2.kf.setImage(with: URL(string: imageUrls[1]))
                            }
                        }
                    }
                case .failure(let error):
                    print("데이터 로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    //새로고침 함수
    @objc private func didPullToRefresh() {
        // 필요에 따라 여러 API 호출을 재실행합니다.
        fetchWeatherData()
        fetchVisualCrossingWeatherData(for: "Seoul")
        updateYesterdayWeatherUI()
        loadRecapData()
        
        // 만약 다른 업데이트 작업이 필요하다면 추가
        
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
}


