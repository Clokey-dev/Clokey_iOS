import Foundation
import UIKit
import SnapKit
import Then
import Kingfisher

class BlockUserCell: UICollectionViewCell {
    static let identifier = "BlockUserCell"
    
    private var isBlocked: Bool = true
    
    // 차단 해제 액션 클로저
    private var unblockAction: ((String) -> Void)?
    
    // MARK: - UI Components
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .systemGray5
    }
    
    private let userInfoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
    }
    
    private let userIdLabel = UILabel().then {
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    
    private let nicknameLabel = UILabel().then {
        $0.font = .ptdRegularFont(ofSize: 12)
        $0.textColor = .gray
    }
    
    let blockButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "차단 해제"
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .mainBrown800
        configuration.cornerStyle = .medium
        
        let button = UIButton(configuration: configuration)
        button.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 16)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byClipping
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 5, bottom: 12, trailing: 5)
            config.baseBackgroundColor = .clear
            button.configuration = config
        } else {
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 5, bottom: 12, right: 5)
        }
        button.layer.cornerRadius = 10
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActions()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(userInfoStackView)
        contentView.addSubview(blockButton)
        
        userInfoStackView.addArrangedSubview(userIdLabel)
        userInfoStackView.addArrangedSubview(nicknameLabel)
        
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        userInfoStackView.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(blockButton.snp.leading).offset(-12)
        }
        
        blockButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.greaterThanOrEqualTo(86)
            $0.height.equalTo(30)
        }
    }
    
    // MARK: - Actions
    private func setupActions() {
        blockButton.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
    }
    
    @objc private func blockButtonTapped() {
        guard let userId = userIdLabel.text else { return }
        unblockAction?(userId)
    }
    
    // MARK: - Configure
    func configure(with user: BlockUserModel, unblockAction: @escaping (String) -> Void) {
        self.unblockAction = unblockAction
        
        userIdLabel.text = user.userId
        nicknameLabel.text = user.nickname
        
        if let url = URL(string: user.profileImageUrl) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "profile_basic"))
        }
        
        isBlocked = user.isBlocked
        updateBlockButton(isBlocked: isBlocked)
    }
    
    func updateBlockButton(isBlocked: Bool) {
        var configuration = UIButton.Configuration.plain()
        configuration.cornerStyle = .medium
        
        blockButton.layer.cornerRadius = 10
        
        if isBlocked {
            // 차단된 상태: "차단 해제"
            configuration.title = "차단 해제"
            configuration.baseForegroundColor = .white
            configuration.background.backgroundColor = .mainBrown800
            blockButton.layer.borderWidth = 1
            blockButton.layer.borderColor = UIColor.mainBrown800.cgColor
        } else {
            // 차단 해제 상태: "차단하기"
            configuration.title = "차단하기"
            configuration.baseForegroundColor = .black
            configuration.background.backgroundColor = .white
            blockButton.layer.borderWidth = 1
            blockButton.layer.borderColor = UIColor.black.cgColor
        }
        
        blockButton.configuration = configuration
    }
}
