//
//  Slider.swift
//  Clokey
//
//  Created by 소민준 on 1/31/25.
//

import UIKit
import SnapKit

/// 두 개의 슬라이더 핸들과 선택된 값 사이에 동적 그라데이션이 적용되는 커스텀 슬라이더
final class Slider: UIControl {
    
    // MARK: - 상수
    private enum Constant {
        static let barRatio = 1.0 / 12.0 // 트랙 높이를 슬라이더 높이의 1/10로 설정
    }

    // MARK: - UI 구성 요소
    private let lowerThumbButton: ThumbButton = {
        let button = ThumbButton()
        button.isUserInteractionEnabled = false // 버튼 자체는 터치를 비활성화
        return button
    }()
    
    
    private let upperThumbButton: ThumbButton = {
        let button = ThumbButton()
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let lowerThumbLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .brown
        label.textAlignment = .center
        label.alpha = 0 
        return label
    }()
    private let upperThumbLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .brown
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
   
    
    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "mainBrown50")?.withAlphaComponent(0.3)
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(named: "mainBrown200")?.cgColor
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 5
        return view
    }()

    private let trackTintView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 5
        return view
    }()
    

    // MARK: - 속성
    var minValue = 0.0 {
        didSet { self.lower = self.minValue } // minValue 변경 시 lower 값을 업데이트
    }
    var maxValue = 10.0 {
        didSet { self.upper = self.maxValue } // maxValue 변경 시 upper 값을 업데이트
    }
    var lower = 0.0 {
        didSet {
            self.updateLayout(lower, true)
            self.updateGradient() // 값이 변경되면 그라디언트를 업데이트
        }
    }
    var upper = 0.0 {
        didSet {
            self.updateLayout(upper, false)
            self.updateGradient() // 값이 변경되면 그라디언트를 업데이트
        }
    }
    var lowerThumbColor = UIColor.white {
        didSet { self.lowerThumbButton.backgroundColor = self.lowerThumbColor }
    }
    var upperThumbColor = UIColor.white {
        didSet { self.upperThumbButton.backgroundColor = self.upperThumbColor }
    }
    var trackColor = UIColor.lightGray {
        didSet { self.trackView.backgroundColor = self.trackColor }
    }
    
    private var previousTouchPoint = CGPoint.zero // 마지막 터치 지점 기록
    private var isLowerThumbViewTouched = false // 현재 하단 슬라이더 핸들이 터치되었는지 여부
    private var isUpperThumbViewTouched = false // 현재 상단 슬라이더 핸들이 터치되었는지 여부
    private var leftConstraint: Constraint? // 하단 슬라이더 핸들의 제약 조건
    private var rightConstraint: Constraint? // 상단 슬라이더 핸들의 제약 조건
    private var thumbViewLength: Double {
        Double(self.bounds.height) // 슬라이더 높이를 기준으로 핸들 크기 계산
    }

    // MARK: - 초기화
    required init?(coder: NSCoder) {
        fatalError("xib는 구현되지 않았습니다.")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        // 서브뷰 추가
        self.addSubview(lowerThumbLabel)
        self.addSubview(upperThumbLabel)
        self.addTarget(self, action: #selector(updateThumbLabels), for: .valueChanged)
        self.addSubview(self.trackView)
        self.addSubview(self.trackTintView)
        self.addSubview(self.lowerThumbButton)
        self.addSubview(self.upperThumbButton)
        
        // 하단 핸들 배치
        self.lowerThumbButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.right.lessThanOrEqualTo(self.upperThumbButton.snp.left)
            $0.left.greaterThanOrEqualToSuperview()
            $0.width.equalTo(self.snp.height)
            self.leftConstraint = $0.left.equalTo(self.snp.left).priority(999).constraint
        }
        
        // 상단 핸들 배치
        self.upperThumbButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.greaterThanOrEqualTo(self.lowerThumbButton.snp.right)
            $0.right.lessThanOrEqualToSuperview()
            $0.width.equalTo(self.snp.height)
            self.rightConstraint = $0.left.equalTo(self.snp.left).priority(999).constraint
        }
        
        // 트랙 배치
        self.trackView.snp.makeConstraints {
            $0.left.right.centerY.equalToSuperview()
            $0.height.equalTo(8)
        }

        self.trackTintView.snp.makeConstraints {
            $0.left.equalTo(lowerThumbButton.snp.right)
            $0.right.equalTo(upperThumbButton.snp.left)
            $0.top.bottom.equalTo(trackView)
        }
        
    }

    // MARK: - 터치 처리
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
        // 터치가 두 핸들 중 하나에만 반응하도록 설정
        return self.lowerThumbButton.frame.contains(point) || self.upperThumbButton.frame.contains(point)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        self.previousTouchPoint = touch.location(in: self)
        self.isLowerThumbViewTouched = self.lowerThumbButton.frame.contains(self.previousTouchPoint)
        self.isUpperThumbViewTouched = self.upperThumbButton.frame.contains(self.previousTouchPoint)
        
        if self.isLowerThumbViewTouched {
            self.lowerThumbButton.isSelected = true
        } else if self.isUpperThumbViewTouched {
            self.upperThumbButton.isSelected = true
        }
  
        UIView.animate(withDuration: 0.2) {
            self.lowerThumbLabel.alpha = 1
            self.upperThumbLabel.alpha = 1
        }
        
        self.updateThumbLabels()
        
        return self.isLowerThumbViewTouched || self.isUpperThumbViewTouched
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        let touchPoint = touch.location(in: self)
        defer {
            self.previousTouchPoint = touchPoint
            self.sendActions(for: .valueChanged)
        }
        
        let drag = Double(touchPoint.x - self.previousTouchPoint.x)
        let scale = self.maxValue - self.minValue
        let scaledDrag = scale * drag / Double(self.bounds.width - self.thumbViewLength)
        
        if self.isLowerThumbViewTouched {
            self.lower = (self.lower + scaledDrag).clamped(to: (self.minValue...self.upper))
        } else if self.isUpperThumbViewTouched {
            self.upper = (self.upper + scaledDrag).clamped(to: (self.lower...self.maxValue))
        }
        
        self.updateThumbLabels()
        
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        self.sendActions(for: .valueChanged)
        
        self.lowerThumbButton.isSelected = false
        self.upperThumbButton.isSelected = false

    
        UIView.animate(withDuration: 0.3) {
            self.lowerThumbLabel.alpha = 0
            self.upperThumbLabel.alpha = 0
        }
    }

    // MARK: - 그라디언트 업데이트
    private func updateGradient() {
        trackTintView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.mainBrown50.withAlphaComponent(0.8).cgColor,
            UIColor.mainBrown800.withAlphaComponent(0.5).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.8, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = trackTintView.bounds

        trackTintView.layer.insertSublayer(gradientLayer, at: 0)
    }
    private var lowerPositionRatio: Double {
        return (lower - minValue) / (maxValue - minValue)
    }
    
    private var upperPositionRatio: Double {
        return (upper - minValue) / (maxValue - minValue)
    }
    @objc private func updateThumbLabels() {
        let totalWidth = self.frame.width
        let totalRange = self.maxValue - self.minValue
        let perDegreeWidth = totalWidth / CGFloat(totalRange)

        let lowerX = self.lowerThumbButton.center.x
        let upperX = self.upperThumbButton.center.x

        let labelOffset: CGFloat = -30

        lowerThumbLabel.text = "\(Int(self.lower))°"
        upperThumbLabel.text = "\(Int(self.upper))°"

        lowerThumbLabel.frame = CGRect(
            x: lowerX - 15,
            y: self.lowerThumbButton.frame.origin.y + labelOffset,
            width: 40,
            height: 20
        )

        upperThumbLabel.frame = CGRect(
            x: upperX - 15,
            y: self.upperThumbButton.frame.origin.y + labelOffset,
            width: 40,
            height: 20
        )
    }
    
    // MARK: - 레이아웃 업데이트
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient() // 레이아웃 변경 시 그라디언트 업데이트
    }
    
    private func updateLayout(_ value: Double, _ isLowerThumb: Bool) {
        DispatchQueue.main.async {
            let startValue = value - self.minValue
            let length = self.bounds.width - self.thumbViewLength
            let offset = startValue * length / (self.maxValue - self.minValue)
            
            if isLowerThumb {
                self.leftConstraint?.update(offset: offset)
            } else {
                self.rightConstraint?.update(offset: offset)
            }
        }
    }
}

// MARK: - 커스텀 버튼 클래스
class RoundableButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }
}

class ThumbButton: RoundableButton {
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = .white
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
        self.layer.cornerRadius = 10
        self.snp.makeConstraints { $0.width.height.equalTo(20) }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - 유틸리티 확장
private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
    
}
