//
//  CustomActionSheetViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import UIKit
import SnapKit
import Then


protocol CustomActionSheetDelegate: AnyObject {
    // 글 삭제 후 현재 화면을 닫기 위한 delegte
    func didDeleteHistory()
}

class CustomActionSheetViewController: UIViewController {
    
    // MARK: - Properties

    weak var delegate: CustomActionSheetDelegate?
    private let historyId: Int
    private let historyService = HistoryService()
    
    // MARK: - Init
    
    init(historyId: Int) {
        self.historyId = historyId
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
    
    private let editButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
        configuration.image = UIImage(named: "edit_icon")?.resized(to: CGSize(width: 36, height: 36))
        configuration.imagePadding = 8

        // 폰트 & 텍스트 크기 조절
        let titleFont = UIFont.ptdMediumFont(ofSize: 18)
        let attributedString = NSAttributedString(
            string: "편집하기",
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

    
    private let deleteButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
        configuration.image = UIImage(named: "delete_icon")?.resized(to: CGSize(width: 36, height: 36))
        configuration.imagePadding = 8

        // 폰트 & 텍스트 크기 조절
        let titleFont = UIFont.ptdMediumFont(ofSize: 18)
        let attributedString = NSAttributedString(
            string: "삭제하기",
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
        
        containerView.addSubview(editButton)
        containerView.addSubview(deleteButton)
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(140)
        }
        
        editButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        // 처음에는 시트를 화면 밖에 위치시킴
        containerView.transform = CGAffineTransform(translationX: 0, y: 180)
    }
    
    private func setupActions() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(dimmedTap)
        
        editButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
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
    
    @objc private func shareButtonTapped() {
        print("본문가기 tapped")
        hideSheet()
    }
    
    @objc private func deleteButtonTapped() {
        historyService.historyDelete(historyId: historyId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:  
                DispatchQueue.main.async {
                    self.hideSheet { [weak self] in
                        self?.delegate?.didDeleteHistory()
                    }
                }
            case .failure(let error):
                print("기록 삭제 에러: \(error.localizedDescription)")
            }
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
