import UIKit

final class EmptyStateView: UIView {
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "empty_icon") // 비어 있을 때 보여줄 이미지
        $0.contentMode = .scaleAspectFit
    }
    
    private let mainMessageLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.textAlignment = .center
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
    }
    
    private let subMessageLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.textAlignment = .center
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.numberOfLines = 2
    }
    
    // MARK: - Init
    /// mainMessage: 크게 보여줄 문구
    /// subMessage: 그 아래에 작게 보여줄 문구
    init(mainMessage: String, subMessage: String) {
        super.init(frame: .zero)
        mainMessageLabel.text = mainMessage
        subMessageLabel.text = subMessage
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        addSubview(imageView)
        addSubview(mainMessageLabel)
        addSubview(subMessageLabel)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30) // 살짝 위로 올려서 배치
            make.width.height.equalTo(55)
        }
        
        mainMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        subMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(mainMessageLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
