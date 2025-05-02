//
//  FollowProfileActionViewController.swift
//  Clokey
//
//  Created by 한금준 on 3/12/25.
//

import UIKit
import SnapKit
import Then

protocol FollowProfileActionDelegate: AnyObject {
    func didReportUser()
    func didBlockUser()
}

class FollowProfileActionViewController: UIViewController {
    private let followProfileView = FollowProfileView()

    // MARK: - Properties

    weak var delegate: FollowProfileActionDelegate?
    private let clokeyId: String
    
    // MARK: - Init
    
    init(clokeyId: String) {
        self.clokeyId = clokeyId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 컨테이너 뷰
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    // 신고하기 버튼
    private let reportButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
        configuration.image = UIImage(named: "report_icon")?.resized(to: CGSize(width: 36, height: 36))
        configuration.imagePadding = 8

        // 폰트 & 텍스트 크기 조절
        let titleFont = UIFont.ptdMediumFont(ofSize: 18)
        let attributedString = NSAttributedString(
            string: "신고하기",
            attributes: [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
        )
        configuration.attributedTitle = AttributedString(attributedString)

        let button = UIButton(configuration: configuration)
        button.contentHorizontalAlignment = .leading
        return button
    }()

    // 차단하기 버튼
    private let blockButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
        configuration.image = UIImage(named: "block_icon")?.resized(to: CGSize(width: 36, height: 36))
        configuration.imagePadding = 8

        // 폰트 & 텍스트 크기 조절
        let titleFont = UIFont.ptdMediumFont(ofSize: 18)
        let attributedString = NSAttributedString(
            string: "차단하기",
            attributes: [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
        )
        configuration.attributedTitle = AttributedString(attributedString)

        let button = UIButton(configuration: configuration)
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    private let dimmedView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSheet()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        
        containerView.addSubview(reportButton)
        containerView.addSubview(blockButton)
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(140)
        }
        
        reportButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        blockButton.snp.makeConstraints {
            $0.top.equalTo(reportButton.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        // 처음에는 시트를 화면 밖에 위치시킴
        containerView.transform = CGAffineTransform(translationX: 0, y: 180)
    }
    
    private func setupActions() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(dimmedTap)
        
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        blockButton.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Animation
    private func showSheet() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.containerView.transform = .identity
            self.dimmedView.alpha = 1.0
        }
    }
    
    private func hideSheet(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.frame.height)
            self.dimmedView.alpha = 0.0
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    // MARK: - Actions
    @objc private func dimmedViewTapped() {
        hideSheet()
    }
    
    // 신고 버튼
    @objc private func reportButtonTapped() {
        dismiss(animated: false) {
            self.delegate?.didReportUser() // Delegate 호출
        }
        print("신고해~")
    }
    
    // 차단 버튼
    @objc private func blockButtonTapped() {
        dismiss(animated: false) {
            self.delegate?.didBlockUser() // Delegate 호출
        }
        print("차단해~")
    }

}
