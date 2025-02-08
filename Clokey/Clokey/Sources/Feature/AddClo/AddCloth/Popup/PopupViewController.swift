//
//  PopupViewController.swift
//  Clokey
//
//  Created by 소민준 on 2/1/25.
//

import UIKit
import SnapKit
import Then

class PopupViewController: UIViewController {
    var clothName: String? // 전달받은 옷 이름
    var season: Set<String> = []
    var selectedSeasons: Set<String> = [] {
        didSet {
            updateSeasonButtons() // 값 변경 시 업데이트
            
            // 선택된 계절을 영어로 변환
            let seasonMapping: [String: String] = [
                "봄": "Spring",
                "여름": "Summer",
                "가을": "Fall",
                "겨울": "Winter"
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
    
    var clothImage: UIImage? // 전달받은 이미지
    
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
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
    }

    private let completeButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 8
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.nameLabel.text = clothName
        popupView.imageView.image = clothImage
        
        if isPublicSelected == true {
            popupView.publicButton.setImage(UIImage(named: "public_icon"), for: .normal)
        }else {
            popupView.publicButton.setImage(UIImage(named: "private_icon"), for: .normal)
        }
        
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
        
        print(imageUrl)
        print(brand)
        
        setupUI()
        // 🔹 completeButton에 Target-Action 추가
        completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        
        updateSeasonButtons() // 초기 상태 업데이트
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(popupView) // ✅ PopupView 추가
        view.addSubview(addButton)
        view.addSubview(completeButton)

        // ✅ 타이틀 상단 고정
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalToSuperview()
        }

        // ✅ PopupView 레이아웃 (높이 지정해서 안 보이는 문제 해결!)
        // ✅ titleLabel과 popupView 사이 간격을 충분히 확보
        popupView.snp.remakeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(34) // 기존 20 -> 40으로 증가
            $0.centerX.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.greaterThanOrEqualTo(508) // 최소 높이 증가
        }
        // ✅ 버튼 배치 (하단 고정)
        addButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-44)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(170)
            $0.height.equalTo(54)
        }

        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-44)
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
    
    // 🔹 completeButton 눌렀을 때 실행될 메서드
    @objc private func didTapCompleteButton() {
        // MainViewController로 이동
//        let mainVC = MainViewController()
//        
//        // 네비게이션 컨트롤러가 있을 경우 Push
//        if let navigationController = navigationController {
//            navigationController.setViewControllers([mainVC], animated: true) // 🔥 기존 스택을 교체하고 MainViewController로 이동
//        } else {
//            // 네비게이션 컨트롤러가 없을 경우 모달로 표시
//            mainVC.modalPresentationStyle = .fullScreen
//            present(mainVC, animated: true, completion: nil) // 🔥 모달 방식으로 MainViewController 이동
//        }
        let successVC = SuccessViewController()
        
        successVC.modalPresentationStyle = .fullScreen // ✅ 전체 화면 모달
        navigationController?.pushViewController(successVC, animated: true)
        
//        let addClothesRequestDTO = AddClothesRequestDTO(
//            categoryId: 1,
//            name: clothName!,
//            season: Array(season),
//            tempUpperBound: maxTemp!,
//            tempLowerBound: minTemp!,
//            thicknessLevel: thicknessLevel!,
//            visibility: visibility!,
//            clothUrl: imageUrl!,
//            brand: brand!
//        )
//        let clothesService = ClothesService()
//        clothesService.addClothes(data: addClothesRequestDTO) { result in
//            switch result {
//            case .success(let response):
//                print("옷 추가 성공: \(response)")
//            case .failure(let error):
//                print("옷 추가 실패: \(error.localizedDescription)")
//            }
//        }
    }
}
