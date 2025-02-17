//
//  ThickSlider.swift
//  Clokey
//
//  Created by 소민준 on 1/31/25.
//

import UIKit

class ThickSlider: UISlider {
    
    private let stepCount = 6  // 0~5 총 6개의 값
    private var circles: [UIView] = []
    private var temperatureLabels: [UILabel] = [] //  숫자 라벨 배열 추가
    private let trackLayer = CAShapeLayer()  // 트랙을 직접 그림
    
    private let circleSize: CGFloat = 12
    private let thumbSize: CGFloat = 20
    private let selectedColor = UIColor.mainBrown800 // mainbrown800
    private let borderColor = UIColor.mainBrown400.cgColor  // 원 테두리 색상
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSlider()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSlider()
    }
    
    private func configureSlider() {
        minimumValue = 0
        maximumValue = Float(stepCount - 1)
        
        isContinuous = false
        value = round(value)  // 처음 값도 정수로 맞추기
        
                
        
        // 기본 트랙 숨기고, 커스텀 트랙을 그릴 준비
        minimumTrackTintColor = .clear
        maximumTrackTintColor = .clear
        
        // Thumb를 완전한 brown으로 설정
        let thumbColor = UIColor(named: "mainbrown800") ?? UIColor.mainBrown400
            
        setThumbImage(createThumbImage(size: thumbSize, color: selectedColor), for: .normal)
        
        createTrackLayer()  // 커스텀 트랙 추가
        createCircles()  // 눈금 원들 추가
        createTemperatureLabels()  //  숫자 라벨 추가
        updateCircles()  // 원 위치 업데이트
    }
    
    // MARK: -  트랙(슬라이더 선) 직접 그리기 (원을 뚫고 지나가지 않게!)
    private func createTrackLayer() {
        trackLayer.allowsEdgeAntialiasing = true  // 안티앨리어싱 활성화 (터치 영향 최소화)
        trackLayer.contentsScale = UIScreen.main.scale  // 고해상도 유지
        layer.insertSublayer(trackLayer, at: 0)  // 트랙을 맨 아래 배치
        updateTrackLayer()
    }
    
    private func updateTrackLayer() {
        let path = UIBezierPath()
        let trackRect = self.trackRect(forBounds: bounds)
        let thumbRect = self.thumbRect(forBounds: trackRect, trackRect: trackRect, value: minimumValue)
        let spacing = (trackRect.width - thumbRect.width) / CGFloat(stepCount - 1)
        
        var lastX: CGFloat = trackRect.origin.x + (thumbRect.width / 2)
        let yPosition = bounds.height / 2
        
        path.move(to: CGPoint(x: lastX, y: yPosition))
        
        for i in 0..<stepCount {
            let xPosition = trackRect.origin.x + (CGFloat(i) * spacing) + (thumbRect.width / 2)
            
            // 원을 피해서 선을 그리기 위해 offset 조정
            if i > 0 {
                path.addLine(to: CGPoint(x: xPosition - (circleSize / 2), y: yPosition))
            }
            
            lastX = xPosition + (circleSize / 2)
            path.move(to: CGPoint(x: lastX, y: yPosition))
        }
        
        trackLayer.path = path.cgPath
        
        trackLayer.strokeColor = UIColor.mainBrown400.cgColor
        trackLayer.lineWidth = 2
        trackLayer.fillColor = UIColor.clear.cgColor
    }
    
    // MARK: -  원(circle) 추가 (트랙 위로 선이 지나가지 않게)
//    private func createCircles() {
//        for _ in 0..<stepCount {
//            let circle = UIView()
//            circle.layer.cornerRadius = circleSize / 2
//            circle.layer.borderWidth = 2
//            circle.layer.borderColor = borderColor
//            circle.backgroundColor = .white  // 트랙이 지나가지 않도록 배경을 흰색으로 설정
//            addSubview(circle)
//            circles.append(circle)
//
//        }
//    }
    
    //  각 점(원) 생성 및 제스처 추가
    private func createCircles() {
        for index in 0..<stepCount {
            let circle = UIView()
            circle.layer.cornerRadius = circleSize / 2
            circle.layer.borderWidth = 2
            circle.layer.borderColor = borderColor
            circle.backgroundColor = .white  // 기본 흰색
            addSubview(circle)
            circles.append(circle)
            
            // 각 점(원)에 제스처 추가
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(circleTapped(_:)))
            circle.addGestureRecognizer(tapGesture)
            circle.tag = index  //  각 점에 고유 태그 설정
        }
    }

    // 🎯 점(원)을 눌렀을 때 동작
    @objc private func circleTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedCircle = sender.view else { return } // 눌린 점 확인
        let selectedIndex = selectedCircle.tag  // 태그에서 인덱스 가져오기
        
        //  슬라이더 값 업데이트
        let stepValue = Float(selectedIndex)
        setValue(stepValue, animated: true)
        
        //  UI 업데이트
        highlightSelectedCircle()
        layoutIfNeeded()
    }
    
    @objc private func sliderValueChanged() {
        
        highlightSelectedCircle()
    }

    @objc private func sliderEnded() {
        let stepValue = round(value)  //  가장 가까운 정수 값으로 정렬
        UIView.animate(withDuration: 0.2, animations: { //  애니메이션 적용
            self.setValue(stepValue, animated: true)
            self.layoutIfNeeded() //  강제 UI 업데이트
        })
        highlightSelectedCircle()
    }
    
    //  숫자 라벨 추가
    private func createTemperatureLabels() {
        for i in 0..<stepCount {
            let label = UILabel()
            label.text = "\(i)"
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = .black
            label.textAlignment = .center
            addSubview(label)
            temperatureLabels.append(label)
        }
    }
    
    private func updateCircles() {
        let trackRect = self.trackRect(forBounds: bounds)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: minimumValue)
        let spacing = (trackRect.width - thumbRect.width) / CGFloat(stepCount - 1)
        
        for (index, circle) in circles.enumerated() {
            let xPosition = trackRect.origin.x + (CGFloat(index) * spacing) + (thumbRect.width / 2) - (circleSize / 2)
            let yPosition = bounds.height / 2 - circleSize / 2
            circle.frame = CGRect(x: xPosition, y: yPosition, width: circleSize, height: circleSize)
        }
        
        updateTemperatureLabels() //  숫자 위치 업데이트
    }
    
    //  숫자 라벨 위치 업데이트
    private func updateTemperatureLabels() {
        let trackRect = self.trackRect(forBounds: bounds)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: minimumValue)
        let spacing = (trackRect.width - thumbRect.width) / CGFloat(stepCount - 1)
        
        for (index, label) in temperatureLabels.enumerated() {
            let xPosition = trackRect.origin.x + (CGFloat(index) * spacing) + (thumbRect.width / 2) - 10
            let yPosition = bounds.height / 2 + 20 //  트랙 아래로 배치
            label.frame = CGRect(x: xPosition, y: yPosition, width: 20, height: 20)
        }
    }
    
   

    private func highlightSelectedCircle() {
        let selectedIndex = Int(value.rounded()) // 🎯 현재 선택된 인덱스
        
        for (index, circle) in circles.enumerated() {
            UIView.animate(withDuration: 0.2) {
                if index == selectedIndex {
                    circle.backgroundColor = self.selectedColor //  선택된 원 색상 변경 (브라운)
                    circle.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) // 크기 키우기 (1.5배)
                    circle.layer.borderColor = UIColor.mainBrown800.cgColor // 테두리 검은색 유지
                } else {
                    circle.backgroundColor = .white //  나머지는 흰색 유지
                    circle.transform = CGAffineTransform.identity //  원래 크기로 복귀
                    circle.layer.borderColor = UIColor.mainBrown400.cgColor // 테두리 검은색 유지
                }
            }
        }
    
    }
    
    private func createThumbImage(size: CGFloat, color: UIColor) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: size, height: size)
            let path = UIBezierPath(ovalIn: rect)
            color.setFill()
            path.fill()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCircles()
        updateTrackLayer()
        highlightSelectedCircle()
        self.superview?.bringSubviewToFront(self)
        
        // 🎯 정수 값에서만 thumb가 정렬되도록 강제 업데이트
        if self.isTracking == false { // 터치 중이 아닐 때만 적용
            let stepValue = round(value)
            setValue(stepValue, animated: false)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(dx: -7, dy: -7) // 터치 영역 확대
        return expandedBounds.contains(point)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
}
