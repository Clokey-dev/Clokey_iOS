//
//  WeatherChooseViewController.swift
//  Clokey
//
//  Created by 소민준 on 1/31/25.
//


import UIKit
import SnapKit

class WeatherChooseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - UI Components
    
    ///  네비게이션 바
    private let customNavBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    ///  뒤로가기 버튼
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left")?
            .withTintColor(.black, renderingMode: .alwaysOriginal) //  아이콘 색상 변경 (검은색)
        
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFit //  아이콘 비율 유지
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    ///  타이틀 ("옷 추가")
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "옷 추가"
        label.font = UIFont.ptdBoldFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    private var temperatureLabels: [UILabel] = []
    
    ///  온도 값 배열
    private let temperatureValues = [-20, -10, 0, 10, 20, 30, 40]
    
    ///  질문 타이틀
   
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "주로 어떤 날씨에 착용하세요?"
        label.font = UIFont.ptdBoldFont(ofSize: 24)
        label.textAlignment = .left //  왼쪽 정렬로 변경
        label.textColor = .black
        return label
    }()

    ///  설명 라벨
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "날씨를 기반으로 알맞은 옷, 추천해 드릴게요!"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .left //  왼쪽 정렬로 변경
        return label
    }()
    //가온데 온도계 사진
    private let thermometerIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "thermo_icon") //  thermo.icon 적용
        imageView.contentMode = .scaleAspectFit
        return imageView
        
    }()
    
    ///  계절 버튼 배열
    private var seasonButtons: [UIButton] = []
    
    ///  계절별 온도 범위
    private let seasonTemperatureRanges: [String: (min: Float, max: Float)] = [
        "봄": (7, 18),
        "여름": (18, 40),
        "가을": (7, 18),
        "겨울": (-20, 7)
    ]
    
    ///  선택된 계절 목록
    private var selectedSeasons: Set<String> = []
    
    ///  슬라이더
    private let slider: Slider = {
        let slider = Slider()
        slider.minValue = -20
        slider.maxValue = 40
        slider.lower = -10
        slider.upper = 20
        return slider
    }()
    

    
    
    ///  다음 버튼
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainBrown400
        button.isEnabled = false
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //  Lower Thumb 위에 온도 레이블
    private let lowerThumbLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ptdBoldFont(ofSize: 14)
        label.textColor = .brown
        label.textAlignment = .center
        label.alpha = 0 //  기본적으로 숨김
        return label
    }()
    
    //  Upper Thumb 위에 온도 레이블
    private let upperThumbLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ptdBoldFont(ofSize: 14)
        label.textColor = .brown
        label.textAlignment = .center
        label.alpha = 0 //  기본적으로 숨김
        return label
    }()
    ///  온도 아이콘
    private let temperatureIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "temperatureIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
        
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSeasonButtons()
        setupTemperatureLabels()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        DispatchQueue.main.async {
            self.thermometerIcon.image = UIImage(named: "thermo_icon")
        }
        
        // 네비게이션 바 추가
        view.addSubview(customNavBar)
        customNavBar.addSubview(backButton)
        customNavBar.addSubview(titleLabel)
        view.addSubview(lowerThumbLabel)
        view.addSubview(upperThumbLabel)
        view.addSubview(questionLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(thermometerIcon)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        view.addSubview(buttonStack)
        
        view.addSubview(temperatureIcon)
        view.addSubview(slider)
        view.addSubview(nextButton)
        
        customNavBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalTo(customNavBar)
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(customNavBar)
        }
        
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(customNavBar.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20) //
            $0.trailing.equalToSuperview().offset(-20) //
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-20) 
        }
        
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        temperatureIcon.snp.makeConstraints {
            $0.top.equalTo(buttonStack.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        
        slider.snp.makeConstraints {
            $0.top.equalTo(thermometerIcon.snp.bottom).offset(69) //  아이콘 아래 배치
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        //  다음 버튼 크기를 353 x 54로 설정
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(20) //  좌우 마진 유지
            $0.height.equalTo(54) // 중앙 정렬
            
        }
        
        thermometerIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(309)
            $0.bottom.equalToSuperview().offset(-383)
            $0.leading.equalToSuperview().offset(117)
            $0.trailing.equalToSuperview().offset(-116)
            
            
        }
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }
    
    private func setupSeasonButtons() {
        let seasons = ["봄", "여름", "가을", "겨울"]
        
        for season in seasons {
            let button = UIButton()
            button.setTitle(season, for: .normal)
            button.setTitleColor(UIColor(named: "mainBrown800"), for: .normal) //  글자 색상
            button.layer.borderWidth = 2 //  테두리 추가
            button.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor //  테두리 색상 적용
            button.layer.cornerRadius = 8
            button.backgroundColor = .clear //  기본 배경색 제거
            button.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
            button.addTarget(self, action: #selector(didTapSeasonButton(_:)), for: .touchUpInside)
            
            seasonButtons.append(button)
        }
        
        let buttonStack = UIStackView(arrangedSubviews: seasonButtons)
        buttonStack.axis = .horizontal
        buttonStack.spacing = 11
        buttonStack.distribution = .equalSpacing
        view.addSubview(buttonStack)
        
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(32) //  버튼 높이 고정
        }

        for button in seasonButtons {
            button.snp.makeConstraints {
                $0.width.equalTo(80)
                $0.height.equalTo(32)
            }
        }
    }
    
    // MARK: - 계절 버튼 클릭 이벤트
    @objc private func didTapSeasonButton(_ sender: UIButton) {
        guard let season = sender.titleLabel?.text else { return }

        if selectedSeasons.contains(season) {
            selectedSeasons.remove(season)
            sender.backgroundColor = .clear // 선택 해제 시 배경 투명
            sender.setTitleColor(UIColor(named: "mainBrown800"), for: .normal) //  선택 해제 시 글자 색상 유지
            sender.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor //  테두리 색상 유지
        } else {
            selectedSeasons.insert(season)
            sender.backgroundColor = UIColor(named: "mainBrown800") //  선택 시 배경색 적용 (정확하게 `mainBrown800`)
            sender.setTitleColor(.white, for: .normal) //  선택 시 글자 색상 변경
            sender.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
        }

        updateSliderRange()
        updateNextButtonState()
    }
    
    
    
    // MARK: - 슬라이더 값 업데이트
    private func updateSliderRange() {
        guard !selectedSeasons.isEmpty else {
            slider.lower = slider.minValue
            slider.upper = slider.maxValue
            return
        }
        
        var minTemp: Double = Double.infinity
        var maxTemp: Double = -Double.infinity
        
        for season in selectedSeasons {
            if let range = seasonTemperatureRanges[season] {
                minTemp = min(minTemp, Double(range.min)) //  Float → Double 변환
                maxTemp = max(maxTemp, Double(range.max)) //  Float → Double 변환
            }
        }
        
        slider.lower = minTemp
        slider.upper = maxTemp
        
        updateNextButtonState()
    }
    private func setupTemperatureLabels() {
        for temp in temperatureValues {
            let label = UILabel()
            label.text = "\(temp)°"
            label.font = UIFont.ptdMediumFont(ofSize: 16)
            label.textColor = .black
            label.textAlignment = .center
            view.addSubview(label)
            temperatureLabels.append(label)
        }
        
    }
    
    var clothName: String? // 전달받을 옷 이름
    var categoryName: String?
    var categoryCloth: String?
    var categoryId: Int64?
    
    
    // MARK: - 다음 버튼 액션
    @objc private func didTapNextButton() {
        let nextVC = ThickViewController() //  다음으로 이동할 VC (파일명에 맞게 수정)
        /***/
        nextVC.clothName = clothName // 값 전달
        nextVC.categoryName = categoryName
        nextVC.categoryCloth = categoryCloth
        nextVC.categoryId = categoryId
        nextVC.selectedSeasons = selectedSeasons
        nextVC.minTemp = Int(slider.lower)
        nextVC.maxTemp = Int(slider.upper)
        /***/
        navigationController?.pushViewController(nextVC, animated: true) // 네비게이션 Push 방식으로 이동
    }
    
    private func updateNextButtonState() {
        // 슬라이더가 움직였는지 확인
        let isSliderMoved = slider.lower != -10 || slider.upper != 20  //  초기 값과 비교
        
        //  계절 버튼이 하나 이상 선택되었는지 확인
        let isSeasonSelected = !selectedSeasons.isEmpty
        
        //  둘 중 하나라도 변경되었으면 버튼 활성화
        let shouldEnable = isSliderMoved || isSeasonSelected
        
        nextButton.isEnabled = shouldEnable
        nextButton.backgroundColor = shouldEnable ? .mainBrown800 : .mainBrown400 //  활성화/비활성화 배경색 변경
    }
    
    // MARK: - 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        
        
        let totalWidth = slider.frame.width
        let totalRange = CGFloat(slider.maxValue - slider.minValue)
        let perDegreeWidth = totalWidth / totalRange * 0.95
        
        for (index, temp) in temperatureValues.enumerated() {
            let label = temperatureLabels[index]
            let positionX = CGFloat(temp - Int(slider.minValue)) * perDegreeWidth + slider.frame.minX
            label.frame = CGRect(x: positionX - 10, y: slider.frame.maxY + 12, width: 40, height: 20)
        }
        
        
    }
}
