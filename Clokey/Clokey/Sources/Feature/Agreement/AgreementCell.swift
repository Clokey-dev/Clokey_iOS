//
//  AgreementCell.swift
//  Clokey
//
//  Created by 소민준 on 1/16/25.
//

import UIKit

class AgreementCell: UITableViewCell {
    static let identifier = "AgreementCell"
   
    private let checkBox: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.tintColor = .gray
        return button
    }()

    private let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.isHidden = true
        return view
    }()

//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .black
//        label.numberOfLines = 1
//        return label
//    }()
    
    private let titleLabel: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.numberOfLines = 1
        button.contentHorizontalAlignment = .left
        return button
    }()

    private let arrowButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .gray
        return button
    }()

    var onCheckBoxTapped: (() -> Void)?
    var onArrowButtonTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(checkBox)
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowButton)
        contentView.addSubview(dividerLine)

        checkBox.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
              $0.leading.equalTo(checkBox.snp.trailing).offset(16)
              $0.centerY.equalToSuperview()
              $0.trailing.lessThanOrEqualTo(arrowButton.snp.leading).offset(-8) // ✅ 화살표와 텍스트 겹침 방지
          }

        arrowButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }

        checkBox.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside) // 체크박스 클릭 시 호출
        titleLabel.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
        arrowButton.addTarget(self, action: #selector(didTapArrowButton), for: .touchUpInside) // 화살표 클릭시 호출
    }

    func configure(with agreement: Agreement, isFirst: Bool) {
        let statusText = agreement.isRequired ? "(필수)" : "(선택)"
        let statusAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: agreement.isChecked ? UIColor.pointOrange800 : UIColor.pointOrange400
        ]
        let attributedString = NSMutableAttributedString(string: statusText, attributes: statusAttributes)

        attributedString.append(NSAttributedString(
            string: " \(agreement.title)",
            attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.black]
        ))
//        titleLabel.attributedText = attributedString
        titleLabel.setAttributedTitle(attributedString, for: .normal) // ✅ 수정된 부분


        checkBox.isSelected = agreement.isChecked
        checkBox.tintColor = agreement.isChecked ? .pointOrange800 : .pointOrange400

        dividerLine.isHidden = !isFirst
    }

    @objc private func didTapCheckBox() {
        onCheckBoxTapped?() // 체크박스 클릭 시 onCheckBoxTapped 호출
    }

    @objc private func didTapArrowButton() {
        onArrowButtonTapped?()
    }
}
