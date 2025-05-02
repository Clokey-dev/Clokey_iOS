//
//  SettingView.swift
//  Clokey
//
//  Created by 한금준 on 2/4/25.
//

import UIKit
import SnapKit
import Then

final class SettingView: UIView {
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()
    
    let infoTitleLabel = UILabel().then {
        $0.text = "로그인/회원정보"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    let separatorLine1 = UIView().then {
        $0.backgroundColor = UIColor(red: 107/255, green: 107/255, blue: 107/255, alpha: 1)
    }
    
    let kakaoImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 20
        $0.image = UIImage(named: "kakao_icon")
    }
    
    let emailLabel = UILabel().then {
        $0.text = "email@xxxxx.com"
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .darkGray
    }
    
    // 계정
    let accountTitleLabel = UILabel().then {
        $0.text = "계정"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    let separatorLine4 = UIView().then {
        $0.backgroundColor = UIColor(red: 107/255, green: 107/255, blue: 107/255, alpha: 1)
    }
    
    // 좋아요 한 기록
    let LikedHistoryContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    let LikedHistoryLabel = UILabel().then {
        $0.text = "좋아요 한 기록 "
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let LikedHistoryButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .black
    }

    // 내가 남긴 댓글
    let HistoryCommentContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    let HistoryCommentLabel = UILabel().then {
        $0.text = "내가 남긴 댓글"
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .black
    }

    let HistoryCommentButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .black
    }
    
    // 차단한 계정
    let blokedAccountContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    let blokedAccountLabel = UILabel().then {
        $0.text = "차단한 계정 "
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let blokedAccountButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .black
    }
    // 알림
    let alarmTitleLabel = UILabel().then {
        $0.text = "알림"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    let separatorLine2 = UIView().then {
        $0.backgroundColor = UIColor(red: 107/255, green: 107/255, blue: 107/255, alpha: 1)
    }
    
    let pushLabel = UILabel().then {
        $0.text = "PUSH 알림"
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let pushSwitch = UISwitch().then {
        $0.isOn = false
        $0.onTintColor = UIColor.orange
    }
    
    let marketingLabel = UILabel().then {
        $0.text = "마케팅 알림 수신 동의"
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let marketingSwitch = UISwitch().then {
        $0.isOn = false
        $0.onTintColor = UIColor.orange
//        $0.transform = CGAffineTransform(scaleX: 1.2, y: 0.8) // 크기를 가로 1.2배, 세로 1.2배로 확대
    }
    
    let supportTitleLabel = UILabel().then {
        $0.text = "고객 지원"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    let separatorLine3 = UIView().then {
        $0.backgroundColor = UIColor(red: 107/255, green: 107/255, blue: 107/255, alpha: 1)
    }
    
    let versionLabel = UILabel().then {
        $0.text = "버전 정보"
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let versionInfoLabel = UILabel().then {
        $0.text = "1.0.0"
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .gray
    }
    
    // 문의하기 버튼
    let inquiryContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    let inquiryLabel = UILabel().then {
        $0.text = "문의하기"
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let inquiryButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .black
    }
    
    // 로그아웃 버튼
    let logoutContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    let logoutLabel = UILabel().then {
        $0.text = "로그아웃"
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let logoutButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .black
    }
    
    // 계정 탈퇴 버튼
    let deleteContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    let deleteAccountLabel = UILabel().then {
        $0.text = "계정 탈퇴"
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let deleteAccountButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .black
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(scrollView)
        
        scrollView.addSubview(contentView)

        contentView.addSubviews(
            infoTitleLabel, separatorLine1, kakaoImage, emailLabel, accountTitleLabel,
            separatorLine4, LikedHistoryContainer, LikedHistoryLabel, LikedHistoryButton,
            HistoryCommentContainer, HistoryCommentLabel, HistoryCommentButton,
            blokedAccountContainer, blokedAccountLabel, blokedAccountButton,
            alarmTitleLabel, separatorLine2, pushLabel, pushSwitch, marketingLabel,
            marketingSwitch, supportTitleLabel, separatorLine3, versionLabel,
            versionInfoLabel, inquiryContainer, logoutContainer, deleteContainer
        )

        LikedHistoryContainer.addSubviews(LikedHistoryLabel, LikedHistoryButton)
        HistoryCommentContainer.addSubviews(HistoryCommentLabel, HistoryCommentButton)
        blokedAccountContainer.addSubviews(blokedAccountLabel, blokedAccountButton)
        inquiryContainer.addSubviews(inquiryLabel, inquiryButton)
        logoutContainer.addSubviews(logoutLabel, logoutButton)
        deleteContainer.addSubviews(deleteAccountLabel, deleteAccountButton)
    }

    
    private func setupConstraints() {

        // 스크롤 뷰
        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)/*.offset(10)*/
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().priority(.low)
            $0.width.equalTo(scrollView) // 가로 스크롤 방지
        }

        infoTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }

        separatorLine1.snp.makeConstraints {
            $0.top.equalTo(infoTitleLabel.snp.bottom).offset(9)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        kakaoImage.snp.makeConstraints {
            $0.top.equalTo(separatorLine1.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(CGSize(width: 40, height: 40))
        }

        emailLabel.snp.makeConstraints {
            $0.centerY.equalTo(kakaoImage)
            $0.leading.equalTo(kakaoImage.snp.trailing).offset(15)
        }

        accountTitleLabel.snp.makeConstraints {
            $0.top.equalTo(kakaoImage.snp.bottom).offset(39)
            $0.leading.equalToSuperview().offset(20)
        }

        separatorLine4.snp.makeConstraints {
            $0.top.equalTo(accountTitleLabel.snp.bottom).offset(9)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        // 좋아요 한 기록
        LikedHistoryContainer.snp.makeConstraints {
            $0.top.equalTo(separatorLine4.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        LikedHistoryLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        LikedHistoryButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }

        // 내가 남긴 댓글
        HistoryCommentContainer.snp.makeConstraints {
            $0.top.equalTo(LikedHistoryContainer.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        HistoryCommentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        HistoryCommentButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }

        // 차단한 계정
        blokedAccountContainer.snp.makeConstraints {
            $0.top.equalTo(HistoryCommentContainer.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        blokedAccountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        blokedAccountButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }

        alarmTitleLabel.snp.makeConstraints {
            $0.top.equalTo(blokedAccountLabel.snp.bottom).offset(39)
            $0.leading.equalToSuperview().offset(20)
        }

        separatorLine2.snp.makeConstraints {
            $0.top.equalTo(alarmTitleLabel.snp.bottom).offset(9)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        pushLabel.snp.makeConstraints {
            $0.top.equalTo(separatorLine2.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        pushSwitch.snp.makeConstraints {
            $0.centerY.equalTo(pushLabel)
            $0.trailing.equalToSuperview().offset(-20)
        }

        marketingLabel.snp.makeConstraints {
            $0.top.equalTo(pushLabel.snp.bottom).offset(25)
            $0.leading.equalToSuperview().offset(20)
        }

        marketingSwitch.snp.makeConstraints {
            $0.centerY.equalTo(marketingLabel)
            $0.trailing.equalToSuperview().offset(-20)
        }

        supportTitleLabel.snp.makeConstraints {
            $0.top.equalTo(marketingLabel.snp.bottom).offset(51)
            $0.leading.equalToSuperview().offset(20)
        }

        separatorLine3.snp.makeConstraints {
            $0.top.equalTo(supportTitleLabel.snp.bottom).offset(9)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        versionLabel.snp.makeConstraints {
            $0.top.equalTo(separatorLine3.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        versionInfoLabel.snp.makeConstraints {
            $0.centerY.equalTo(versionLabel)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // 문의하기
        inquiryContainer.snp.makeConstraints {
            $0.top.equalTo(versionInfoLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        inquiryLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        inquiryButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }

        // 로그아웃
        logoutContainer.snp.makeConstraints {
            $0.top.equalTo(inquiryContainer.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        logoutLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        logoutButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }

        // 계정 탈퇴
        deleteContainer.snp.makeConstraints {
            $0.top.equalTo(logoutContainer.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-20)
        }

        deleteAccountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        deleteAccountButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
