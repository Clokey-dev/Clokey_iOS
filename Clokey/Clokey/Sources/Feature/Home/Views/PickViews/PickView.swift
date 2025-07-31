//
//  PickView.swift
//  Clokey
//
//  Created by 한금준 on 1/11/25.
//

import UIKit
import Then
import SnapKit

final class PickView: UIView {

    // MARK: - Subviews

    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    let contentView = UIView().then {
        $0.backgroundColor = .white
    }

    let timeLabel = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.text = "12:00 PM 대한민국 ??? 기준"
    }

    let appleWeatherLabel = UILabel().then {
        let text = " Weather"
        let attr = NSMutableAttributedString(string: text)
        attr.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: text.count))
        attr.addAttribute(.font, value: UIFont.ptdMediumFont(ofSize: 14), range: NSRange(location: 0, length: text.count))
        $0.attributedText = attr
        $0.textAlignment = .center
        $0.isUserInteractionEnabled = true
    }

    let locationIconView = UIImageView().then {
        $0.image = UIImage(named: "location_icon")
        $0.contentMode = .scaleAspectFit
    }

    let weatherIconView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }

    let temperatureLabel = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.textAlignment = .center
        $0.text = "-1°C"
    }

    let tempDetailsLabel = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.text = "(최고: 3°, 최저: -3°)"
    }

    let temperatureChangeLabel = UILabel().then {
        $0.text = "어제에 비해 기온이 변화 중..."
        $0.textColor = .black
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textAlignment = .center
        $0.backgroundColor = .clear
        $0.layer.borderColor = UIColor.brown.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }

    let weatherImageContainerView = UIView().then {
        $0.backgroundColor = .clear
    }

    let weatherImageView1 = PickView.imageView()
    let weatherImageName1 = PickView.imageLabel()

    let weatherImageView2 = PickView.imageView()
    let weatherImageName2 = PickView.imageLabel()

    let weatherImageView3 = PickView.imageView()
    let weatherImageName3 = PickView.imageLabel()

    let bottomButtonLabel = UILabel().then {
        $0.text = "내 옷 보러가기"
        $0.textColor = .black
        $0.font = UIFont.ptdMediumFont(ofSize: 12)
    }

    let bottomArrowIcon = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFill
    }

    let recapTitleLabel = UILabel().then {
        $0.text = "Recap"
        $0.textColor = .black
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
    }

    let recapSubtitleLabel1 = UILabel().then {
        $0.text = "1년 전 오늘, 00님의 기록이 없어요!"
        $0.textColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.numberOfLines = 0
    }

    let recapSubtitleLabel2 = UILabel().then {
        $0.text = "다른사용자들은 어떤 옷을 입었을까요?"
        $0.textColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.numberOfLines = 0
    }

    let recapImageContainerView = UIView().then {
        $0.backgroundColor = .clear
    }

    let recapImageView1 = PickView.imageView()
    let recapImageView2 = PickView.imageView()

    private let emptyStackView = EmptyStackView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .white

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        [timeLabel, appleWeatherLabel, locationIconView, weatherIconView, temperatureLabel, tempDetailsLabel, temperatureChangeLabel, weatherImageContainerView, bottomButtonLabel, bottomArrowIcon, recapTitleLabel, recapSubtitleLabel1, recapSubtitleLabel2, recapImageContainerView].forEach {
            contentView.addSubview($0)
        }

        [weatherImageView1, weatherImageName1, weatherImageView2, weatherImageName2, weatherImageView3, weatherImageName3].forEach {
            weatherImageContainerView.addSubview($0)
        }

        [recapImageView1, recapImageView2].forEach {
            recapImageContainerView.addSubview($0)
        }
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalToSuperview()
        }

        timeLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide).offset(21)
            $0.leading.equalToSuperview().offset(20)
        }

        appleWeatherLabel.snp.makeConstraints {
            $0.centerY.equalTo(timeLabel)
            $0.trailing.equalTo(locationIconView.snp.leading).offset(-8)
        }

        locationIconView.snp.makeConstraints {
            $0.centerY.equalTo(timeLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(24)
        }

        weatherIconView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(26)
        }

        temperatureLabel.snp.makeConstraints {
            $0.centerY.equalTo(weatherIconView)
            $0.leading.equalTo(weatherIconView.snp.trailing).offset(1)
        }

        tempDetailsLabel.snp.makeConstraints {
            $0.centerY.equalTo(weatherIconView)
            $0.leading.equalTo(temperatureLabel.snp.trailing).offset(3)
        }

        temperatureChangeLabel.snp.makeConstraints {
            $0.top.equalTo(tempDetailsLabel.snp.bottom).offset(11)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }

        weatherImageContainerView.snp.makeConstraints {
            $0.top.equalTo(temperatureChangeLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(170)
        }

        weatherImageView1.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.equalTo(weatherImageView2)
            $0.height.equalTo(148)
        }

        weatherImageName1.snp.makeConstraints {
            $0.top.equalTo(weatherImageView1.snp.bottom).offset(5)
            $0.leading.equalTo(weatherImageView1).offset(2)
            $0.width.equalTo(weatherImageView1).offset(-2)
        }

        weatherImageView2.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(weatherImageView1.snp.trailing).offset(10)
            $0.width.equalTo(weatherImageView3)
            $0.height.equalTo(weatherImageView1)
        }

        weatherImageName2.snp.makeConstraints {
            $0.top.equalTo(weatherImageView2.snp.bottom).offset(5)
            $0.leading.equalTo(weatherImageView2).offset(2)
            $0.width.equalTo(weatherImageView2).offset(-2)
        }

        weatherImageView3.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(weatherImageView2.snp.trailing).offset(10)
            $0.trailing.equalToSuperview()
            $0.width.equalTo(weatherImageView1)
            $0.height.equalTo(weatherImageView1)
        }

        weatherImageName3.snp.makeConstraints {
            $0.top.equalTo(weatherImageView3.snp.bottom).offset(5)
            $0.leading.equalTo(weatherImageView3).offset(2)
            $0.width.equalTo(weatherImageView3).offset(-2)
        }

        bottomButtonLabel.snp.makeConstraints {
            $0.top.equalTo(weatherImageName3.snp.bottom).offset(15)
            $0.trailing.equalToSuperview().inset(30)
        }

        bottomArrowIcon.snp.makeConstraints {
            $0.centerY.equalTo(bottomButtonLabel)
            $0.leading.equalTo(bottomButtonLabel.snp.trailing).offset(5)
            $0.size.equalTo(CGSize(width: 6, height: 12))
        }

        recapTitleLabel.snp.makeConstraints {
            $0.top.equalTo(bottomButtonLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        recapSubtitleLabel1.snp.makeConstraints {
            $0.top.equalTo(recapTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(20)
        }

        recapSubtitleLabel2.snp.makeConstraints {
            $0.top.equalTo(recapSubtitleLabel1.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(20)
        }

        recapImageContainerView.snp.makeConstraints {
            $0.top.equalTo(recapSubtitleLabel2.snp.bottom).offset(9)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(223.22)
            $0.bottom.equalToSuperview().offset(-20)
        }

        recapImageView1.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.width.equalTo(recapImageContainerView.snp.width).multipliedBy(0.5).offset(-5)
        }

        recapImageView2.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(recapImageContainerView.snp.width).multipliedBy(0.5).offset(-5)
        }
    }

    // MARK: - Methods

    func updateEmptyState(isEmpty: Bool) {
        if isEmpty {
            weatherImageContainerView.addSubview(emptyStackView)
            emptyStackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            temperatureChangeLabel.isHidden = true
            bottomButtonLabel.isHidden = true
            bottomArrowIcon.isHidden = true
        } else {
            emptyStackView.removeFromSuperview()
            temperatureChangeLabel.isHidden = false
            bottomButtonLabel.isHidden = false
            bottomArrowIcon.isHidden = false
        }
    }

    func recapNotMe(hidden: Bool) {
        recapSubtitleLabel2.isHidden = hidden
        recapImageContainerView.snp.remakeConstraints {
            $0.top.equalTo(hidden ? recapSubtitleLabel1.snp.bottom : recapSubtitleLabel2.snp.bottom).offset(9)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(223.22)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - Factory

    private static func imageView() -> UIImageView {
        UIImageView().then {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 5
            $0.layer.masksToBounds = true
        }
    }

    private static func imageLabel() -> UILabel {
        UILabel().then {
            $0.font = UIFont.ptdRegularFont(ofSize: 12)
            $0.textColor = .black
            $0.textAlignment = .left
            $0.numberOfLines = 0
            $0.lineBreakMode = .byCharWrapping
        }
    }
}
