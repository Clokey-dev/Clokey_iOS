//
//  PopupViewController.swift
//  Clokey
//
//  Created by 한금준 on 2/1/25.
//

import UIKit
import SnapKit
import Then

class PopupViewController: UIViewController {
    var clothName: String? // 전달받은 옷 이름
    var categoryName: String?
    var categoryCloth: String?
    var categoryId: Int64?
    var season: Set<String> = []
    var selectedSeasons: Set<String> = [] {
        didSet {
            updateSeasonButtons() // 값 변경 시 업데이트
            
            // 선택된 계절을 영어로 변환
            let seasonMapping: [String: String] = [
                "봄": "SPRING",
                "여름": "SUMMER",
                "가을": "FALL",
                "겨울": "WINTER"
            ]
            
            let convertedSeasons = selectedSeasons.compactMap { seasonMapping[$0] }
            season = Set(convertedSeasons) // 영어로 변환된 값을 season에 저장
        }
    }
    var minTemp: Int?
    var maxTemp: Int?
    var thicknessLevel: String?
    var thickCount: Int? = 0 {
        didSet {
            if thickCount == 0 {
                thicknessLevel = "LEVEL_0"
            }else if thickCount == 1 {
                thicknessLevel = "LEVEL_1"
                print("thicknessLevel이 LEVEL_1으로 설정되었습니다.")
            }else if thickCount == 2 {
                thicknessLevel = "LEVEL_2"
            }else if thickCount == 3 {
                thicknessLevel = "LEVEL_3"
            }else if thickCount == 4 {
                thicknessLevel = "LEVEL_4"
            }else if thickCount == 5 {
                thicknessLevel = "LEVEL_5"
            }
        }
    }
    var visibility: String?
    var isPublicSelected: Bool? = true {
        didSet {
            if isPublicSelected == true {
                visibility = "PUBLIC"
            } else {
                visibility = "PRIVATE"
                print("visibility이 PRIVATE으로 설정되었습니다.")
            }
        }
    }
    var imageUrl: String?
    var brand: String?
    
    var cloth: UIImage?
    var clothImage: Data? // 전달받은 이미지
    
    private let popupView = PopupView() // ✅ 뷰 객체만 포함

    private let titleLabel = UILabel().then {
        $0.text = "옷 추가가 완료되었어요!"
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .black
        $0.textAlignment = .center
    }

    private let addButton = UIButton().then {
        $0.setTitle("옷 추가하기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
    }

    private let completeButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 10
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.nameLabel.text = clothName
        popupView.imageView.image = cloth
        
        if isPublicSelected == true {
            popupView.publicButton.setImage(UIImage(named: "public_icon"), for: .normal)
        }else {
            popupView.publicButton.setImage(UIImage(named: "private_icon"), for: .normal)
        }
        
        popupView.categoryButton1.setTitle(categoryName, for: .normal)
        popupView.categoryButton2.setTitle(categoryCloth, for: .normal)
        
        
        popupView.brandNameLabel.text = brand
        popupView.urlGoButton.addTarget(self, action: #selector(urlGoButtonTapped), for: .touchUpInside)
    
        
        print(selectedSeasons)
        
        if let minTemp = minTemp, let maxTemp = maxTemp {
            print("min : \(minTemp), max: \(maxTemp)")
        } else {
            print("min 또는 max 값이 없습니다.")
        }
        
        if let thickCount = thickCount {
            print("thickCount : \(thickCount)")
        } else {
            print("thickCount 값이 없습니다.")
        }
        
        if let isPublicSelected = isPublicSelected {
            print("isPublicSelected : \(isPublicSelected)")
        } else {
            print("isPublicSelected 값이 없습니다.")
        }
    
        
        setupUI()
       
        addButton.addTarget(self, action: #selector(didTapAddClothButton), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        
        updateSeasonButtons() // 초기 상태 업데이트
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(popupView)
        view.addSubview(addButton)
        view.addSubview(completeButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        popupView.layer.cornerRadius = 30 // 원하는 둥글기 정도 (예: 20)
        popupView.clipsToBounds = true
        
        popupView.snp.remakeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(34) // 기존 20 -> 40으로 증가
            $0.centerX.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.greaterThanOrEqualTo(508) // 최소 높이 증가
        }
   
        addButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)/*.offset(-44)*/
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(170)
            $0.height.equalTo(54)
        }

        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)/*.offset(-44)*/
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(170)
            $0.height.equalTo(54)
        }
    }
    
    private func updateSeasonButtons() {
        // 모든 버튼 초기화
        [popupView.springButton, popupView.summerButton, popupView.fallButton, popupView.winterButton].forEach { button in
            button.backgroundColor = UIColor.clear // 기본 배경색
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
            button.backgroundColor = UIColor.clear
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
        }
        
        // 선택된 계절에 따라 배경색 설정
        if selectedSeasons.contains("봄") {
            popupView.springButton.backgroundColor = UIColor(named: "mainBrown800")
            popupView.springButton.setTitleColor(.white, for: .normal)
        }
        if selectedSeasons.contains("여름") {
            popupView.summerButton.backgroundColor = UIColor(named: "mainBrown800")
            popupView.summerButton.setTitleColor(.white, for: .normal)
        }
        if selectedSeasons.contains("가을") {
            popupView.fallButton.backgroundColor = UIColor(named: "mainBrown800")
            popupView.fallButton.setTitleColor(.white, for: .normal)
        }
        if selectedSeasons.contains("겨울") {
            popupView.winterButton.backgroundColor = UIColor(named: "mainBrown800")
            popupView.winterButton.setTitleColor(.white, for: .normal)
        }
    }
    
    @objc private func urlGoButtonTapped() {
        guard let urlString = imageUrl, let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        // URL 열기
        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                print("Opened URL: \(urlString)")
            } else {
                print("Failed to open URL: \(urlString)")
            }
        }
    }
    
    @objc private func didTapAddClothButton() {
        let addClothVC = AddClothViewController()
        navigationController?.pushViewController(addClothVC, animated: true)
        
        guard let categoryId = categoryId,
              let clothName = clothName,
              let maxTemp = maxTemp,
              let minTemp = minTemp,
              let thicknessLevel = thicknessLevel,
              let visibility = visibility,
              let imageUrl = imageUrl,
              let brand = brand,
              let selectedImage = clothImage // UIImage
        else {
            print("필수 데이터 누락 또는 이미지 변환 실패")
            return
        }

        let addClothesRequestDTO = AddClothesRequestDTO(
            categoryId: categoryId,
            name: clothName,
            seasons: Array(season),
            tempUpperBound: maxTemp,
            tempLowerBound: minTemp,
            thicknessLevel: thicknessLevel,
            visibility: visibility,
            clothUrl: imageUrl,
            brand: brand
        )

        let clothesService = ClothesService()

        clothesService.addClothes(imageData: selectedImage, data: addClothesRequestDTO) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("옷 추가 성공: \(response)")
                case .failure(let error):
                    print("옷 추가 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    @objc private func didTapCompleteButton() {
        let successVC = SuccessViewController()
        navigationController?.pushViewController(successVC, animated: true)

        guard let categoryId = categoryId,
              let clothName = clothName,
              let maxTemp = maxTemp,
              let minTemp = minTemp,
              let thicknessLevel = thicknessLevel,
              let visibility = visibility,
              let imageUrl = imageUrl,
              let brand = brand,
              let selectedImage = clothImage // UIImage
        else {
            print("필수 데이터 누락 또는 이미지 변환 실패")
            return
        }

        let addClothesRequestDTO = AddClothesRequestDTO(
            categoryId: categoryId,
            name: clothName,
            seasons: Array(season),
            tempUpperBound: maxTemp,
            tempLowerBound: minTemp,
            thicknessLevel: thicknessLevel,
            visibility: visibility,
            clothUrl: imageUrl,
            brand: brand
        )

        let clothesService = ClothesService()

        clothesService.addClothes(imageData: selectedImage, data: addClothesRequestDTO) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("옷 추가 성공: \(response)")
                case .failure(let error):
                    print("옷 추가 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}
