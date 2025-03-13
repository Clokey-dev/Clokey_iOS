//
//  AccountReportView.swift
//  Report
//
//  Created by 한금준 on 3/5/25.
//

import UIKit
import SnapKit
import Then

class AccountReportView: UIView {

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
        $0.backgroundColor = .lightGray
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

    // 서버 데이터 예시
    private var reasons: [ReportReason] = [
        ReportReason(
            reportType: "FAKE_ACCOUNT",
            title: "허위 계정 또는 사칭입니다.",
            reportContents: [
                "타인을 사칭하거나 거짓 정보를 이용해 만든 계정",
                "공식 브랜드, 인플루언서 등을 사칭한 경우",
                "가짜 계정을 만들어 커뮤니티를 교란하는 경우"
            ]
        ),
        ReportReason(
            reportType: "SPAM",
            title: "스팸 홍보 및 도배 계정입니다.",
            reportContents: [
                "광고성 메시지를 지속적으로 보내는 계정",
                "홍보 목적의 프로필 (상업적 링크 다수 포함)",
                "동일한 내용의 글을 반복적으로 게시하는 계정"
            ]
        ),
        ReportReason(
            reportType: "INAPPROPRIATE_PROFILE",
            title: "부적절한 프로필 정보입니다.",
            reportContents: [
                "음란물, 혐오 표현, 폭력적인 이미지를 프로필 사진으로 설정한 경우",
                "닉네임 또는 상태 메시지에 욕설, 차별적인 표현이 포함된 경우"
            ]
        ),
        ReportReason(
            reportType: "OTHER",
            title: "기타 (직접 입력 가능)",
            reportContents: [
                "위 신고 항목에 해당하지 않지만, 부적절하다고 판단되는 프로필"
            ]
        )
    ]

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

        addSubview(reportTitle)
        // 체크리스트
        for (index, reason) in reasons.enumerated() {
            let reportView = ReportReasonView(title: reason.title, contents: reason.reportContents)
            reportView.tag = index
            reportView.delegate = self
            addSubview(reportView)
            reportViews.append(reportView)
        }

        addSubview(completeButton)
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

        // 신고 사유
        reportTitle.snp.makeConstraints {
            $0.top.equalTo(divideLine.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }

        var previousView: UIView = reportTitle

        for (index, reportView) in reportViews.enumerated() {
            reportView.snp.makeConstraints {
                if index == 0 {
                    $0.top.equalTo(reportTitle.snp.bottom).offset(12)
                } else {
                    let spacing = reportViews[index - 1].isChecked ? 20 : 8
                    $0.top.equalTo(previousView.snp.bottom).offset(spacing)
                }
                $0.leading.trailing.equalToSuperview()
            }
            previousView = reportView
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
}

// MARK: - ReportReasonViewDelegate
extension AccountReportView: ReportReasonViewDelegate {
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
    
    private func updateConstraintsForReportViews() {
        var previousView: UIView = reportTitle
        
        for (index, reportView) in reportViews.enumerated() {
            reportView.snp.updateConstraints {
                if index == 0 {
                    $0.top.equalTo(reportTitle.snp.bottom).offset(12)
                } else {
                    let spacing = reportViews[index - 1].isChecked ? 20 : 8
                    $0.top.equalTo(previousView.snp.bottom).offset(spacing)
                }
            }
            previousView = reportView
        }
        
        self.layoutIfNeeded()
    }
}
