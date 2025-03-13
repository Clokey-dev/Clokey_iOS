//
//  CustomReportView.swift
//  Report
//
//  Created by 한금준 on 3/5/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

class CustomReportView: UIView {
    
    // MARK: - UI Component

    // 계정 정보
    private let infoTitle = UILabel().then {
        $0.text = "계정 정보"
        $0.font = .ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .black
    }

    private let infoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fill
    }

    private let infoImageContainer = UIView().then {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }

    private let infoImage = UIImageView().then {
        $0.image = UIImage(named: "default_profile")
        $0.contentMode = .scaleAspectFit
    }

    private let infoTextStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
    }

    private let infoIdLabel = UILabel().then {
        $0.text = "아이디"
        $0.textColor = .black
        $0.font = .ptdMediumFont(ofSize: 14)
    }

    private let infoNameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.textColor = .black
        $0.font = .ptdRegularFont(ofSize: 12)
    }

    private let divideLine = UIView().then {
        $0.backgroundColor = UIColor(hexCode: "#f1f1f1")
    }
    
    // 댓글/게시물 내용 관련 UI 요소들
    private let contentContainer = UIView().then {
        $0.isHidden = false
    }
    
    private let contentTitle = UILabel().then {
        $0.text = "기록 내용"
        $0.font = .ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .black
    }
    
    private let contentTextLabel = UILabel().then {
        $0.text = "연말 파티 즐거웠다~내용이 추가된다면~~~ 추가된 내용은 아무내용...연말 파티 즐거웠다~내용이 추가된다면~~~ 추가된 내용은 아무내용..."
        $0.font = .ptdRegularFont(ofSize: 12)
        $0.textColor = .black
        $0.numberOfLines = 0
    }

    private let divideLine2 = UIView().then {
        $0.backgroundColor = UIColor(hexCode: "#f1f1f1")
    }
    
    // 신고 사유
    private let reportTitle = UILabel().then {
        $0.text = "신고 사유"
        $0.font = .ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .black
    }

    let completeButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.backgroundColor = UIColor.pointOrange800
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.layer.cornerRadius = 10
    }

    // 서버 데이터를 저장할 배열
    private var reasons: [ReportReason] = []

    private var reportViews: [ReportReasonView] = []
    private var selectedReportViewIndex: Int? = nil

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Method
    
    private func setupView() {
        backgroundColor = .white

        addSubview(infoTitle)
        addSubview(infoStackView)
        infoStackView.addArrangedSubview(infoImageContainer)
        infoImageContainer.addSubview(infoImage)
        infoStackView.addArrangedSubview(infoTextStackView)
        infoTextStackView.addArrangedSubview(infoIdLabel)
        infoTextStackView.addArrangedSubview(infoNameLabel)
        addSubview(divideLine)
        
        addSubview(contentContainer)
        contentContainer.addSubview(contentTitle)
        contentContainer.addSubview(contentTextLabel)
        addSubview(divideLine2)

        addSubview(reportTitle)
        
        // 콘텐츠 컨테이너 기본 숨김 처리 (계정 신고 시에는 필요없음)
        contentContainer.isHidden = true
        divideLine2.isHidden = true

        addSubview(completeButton)
    }
    
    // 서버에서 받은 사용자 정보 업데이트
    func updateUserInfo(clokeyId: String, nickname: String, profileImageUrl: String) {
        infoIdLabel.text = clokeyId
        infoNameLabel.text = nickname
        
        if let url = URL(string: profileImageUrl) {
            infoImage.kf.setImage(with: url, placeholder: UIImage(named: "default_profile"))
        } else {
            infoImage.image = UIImage(named: "default_profile")
        }
    }
    
    // 서버에서 받은 신고 사유 업데이트
    func updateReportReasons(reasons: [ReportReason]) {
        // 기존 신고 사유 뷰 제거
        for view in reportViews {
            view.removeFromSuperview()
        }
        reportViews.removeAll()
        
        // 서버에서 받은 신고 사유로 업데이트
        self.reasons = reasons
        
        // 체크리스트 다시 생성
        for (index, reason) in reasons.enumerated() {
            let reportView = ReportReasonView(title: reason.title, contents: reason.reportContents)
            reportView.tag = index
            reportView.delegate = self
            addSubview(reportView)
            reportViews.append(reportView)
        }
        
        // 제약 조건 업데이트
        updateConstraintsForReportViews()
    }

    private func setupConstraints() {
        // 계정 정보
        infoTitle.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(18)
            $0.leading.equalToSuperview().offset(20)
        }

        infoStackView.snp.makeConstraints {
            $0.top.equalTo(infoTitle.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(46)
        }

        infoImageContainer.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }

        infoImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        infoTextStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
        }

        divideLine.snp.makeConstraints {
            $0.top.equalTo(infoStackView.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        // 댓글/게시물 내용 UI 제약조건
        contentContainer.snp.makeConstraints {
            $0.top.equalTo(divideLine.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
       
        contentTitle.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
       
        contentTextLabel.snp.makeConstraints {
            $0.top.equalTo(contentTitle.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }
       
        divideLine2.snp.makeConstraints {
            $0.top.equalTo(contentTextLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        // 신고 사유
        reportTitle.snp.makeConstraints {
            $0.top.equalTo(divideLine.snp.bottom).offset(12) // 콘텐츠 없을 때는 첫 번째 divideLine 기준
            $0.leading.equalToSuperview().offset(20)
        }

        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(54)
            $0.width.equalTo(353)
        }
    }
    
    // 선택된 신고 사유 정보
    func getSelectedReportReason() -> ReportReason? {
        if let selectedIndex = selectedReportViewIndex {
            return reasons[selectedIndex]
        }
        return nil
    }
    
    // 신고 사유 제약 조건 업데이트
    private func updateConstraintsForReportViews() {
        var previousView: UIView = reportTitle
        
        for (index, reportView) in reportViews.enumerated() {
            reportView.snp.makeConstraints {
                if index == 0 {
                    $0.top.equalTo(reportTitle.snp.bottom).offset(12)
                } else {
                    let spacing = reportViews[index - 1].isChecked ? 20 : 12
                    $0.top.equalTo(previousView.snp.bottom).offset(spacing)
                }
                $0.leading.trailing.equalToSuperview()
            }
            previousView = reportView
        }
        
        self.layoutIfNeeded()
    }
}

// MARK: - ReportReasonViewDelegate
extension CustomReportView: ReportReasonViewDelegate {
    func didToggleCheck(reportView: ReportReasonView, isChecked: Bool) {
        let selectedIndex = reportView.tag
        
        // 체크박스가 선택되었을 때만 처리
        if isChecked {
            if let previousIndex = selectedReportViewIndex, previousIndex != selectedIndex {
                reportViews[previousIndex].setChecked(false)
            }
            
            selectedReportViewIndex = selectedIndex
        } else {
            // 체크 해제
            if selectedReportViewIndex == selectedIndex {
                selectedReportViewIndex = nil
            }
        }
        
        updateConstraintsForReportViews()
    }
}
