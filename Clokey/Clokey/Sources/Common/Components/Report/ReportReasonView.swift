//
//  ReportReasonView.swift
//  Clokey
//
//  Created by 황상환 on 3/9/25.
//

import UIKit
import SnapKit
import Then

protocol ReportReasonViewDelegate: AnyObject {
    func didToggleCheck(reportView: ReportReasonView, isChecked: Bool)
}

class ReportReasonView: UIView {
    
    weak var delegate: ReportReasonViewDelegate?
    
    // MARK: - UI Component
    
    private let checkBox = CheckBox()
    private let titleLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 15)
        $0.textColor = .black
        $0.isUserInteractionEnabled = true
    }

    private let infoContainer = UIView().then {
        $0.backgroundColor = .mainBrown50
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.isHidden = true
    }
    
    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fill
    }

    private var bulletLabels: [BulletPointLabel] = []
    private var infoContainerHeight: Constraint?

    var isChecked: Bool = false {
        didSet {
            checkBox.isChecked = isChecked
            infoContainer.isHidden = !isChecked
            
            updateLayout()
            
            delegate?.didToggleCheck(reportView: self, isChecked: isChecked)
        }
    }
    
    // 외부에서 체크 상태 설정할 수 있는 메서드
    func setChecked(_ checked: Bool) {
        // 델리게이트 호출 없이 내부 상태만 변경
        checkBox.isChecked = checked
        infoContainer.isHidden = !checked
        isChecked = checked
        
        updateLayout()
    }

    // MARK: - Init
    
    init(title: String, contents: [String]) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.setupBulletPoints(contents: contents)

        setupView()
        setupGesture()
        self.snp.makeConstraints {
            $0.height.equalTo(22).priority(.high)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBulletPoints(contents: [String]) {
        for content in contents {
            let bulletLabel = BulletPointLabel(text: content)
            bulletLabels.append(bulletLabel)
            infoStackView.addArrangedSubview(bulletLabel)
        }
    }

    // MARK: -Init
    
    private func setupView() {
        addSubviews(checkBox, titleLabel, infoContainer)
        infoContainer.addSubview(infoStackView)

        checkBox.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(titleLabel)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkBox.snp.trailing).offset(12)
            $0.centerY.equalTo(checkBox)
        }

        infoContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(checkBox.snp.leading)
            $0.trailing.equalToSuperview().offset(-20)
        }

        infoStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(15)
        }
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleCheck))
        titleLabel.addGestureRecognizer(tapGesture)

        let boxTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleCheck))
        checkBox.addGestureRecognizer(boxTapGesture)
    }

    @objc private func toggleCheck() {
        isChecked.toggle()
    }

    private func updateLayout() {
        var totalHeight: CGFloat = 22 // 기본 높이
        
        if isChecked {
            // 각 불릿 포인트의 높이를 계산
            let bulletLabelsHeight = bulletLabels.reduce(0) { sum, label in
                return sum + label.intrinsicContentSize.height
            }
            
            // 스택뷰 간격과 컨테이너 패딩 추가
            let stackSpacing = CGFloat(bulletLabels.count - 1) * infoStackView.spacing
            let containerPadding: CGFloat = 30
            
            totalHeight = bulletLabelsHeight + stackSpacing + containerPadding + 20 // 추가 여백
        }

        self.snp.updateConstraints {
            $0.height.equalTo(totalHeight).priority(.high)
        }

        self.superview?.layoutIfNeeded()
    }
}

// 불릿 포인트 레이블 클래스
class BulletPointLabel: UIView {
    private let bulletLabel = UILabel().then {
        $0.text = "•"
        $0.font = .ptdRegularFont(ofSize: 12)
        $0.textColor = .black
    }
    
    private let textLabel = UILabel().then {
        $0.font = .ptdRegularFont(ofSize: 12)
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    init(text: String) {
        super.init(frame: .zero)
        self.textLabel.text = text
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(bulletLabel)
        addSubview(textLabel)
        
        bulletLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.equalTo(15)
        }
        
        textLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(bulletLabel.snp.trailing)
            $0.trailing.bottom.equalToSuperview()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: textLabel.intrinsicContentSize.height)
    }
}
