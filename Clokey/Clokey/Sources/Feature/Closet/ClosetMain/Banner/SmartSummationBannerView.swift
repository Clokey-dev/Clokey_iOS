import UIKit
import SnapKit
import Then

class SmartSummationBannerView: UIControl {
    
    // MARK: - UI Component
    
    private let bannerImage = UIImageView().then {
        $0.image = UIImage(named: "bannerimage1")
        $0.contentMode = .scaleAspectFit
    }
    
    private let bannerTitle = UILabel().then {
        $0.text = "이번 주 최다 착용 아이템은?"
        $0.font = UIFont.ptdBoldFont(ofSize: 16)
        $0.textColor = UIColor(named: "pointOrange800")
    }
    
    private let bannerDescription = UILabel().then {
        $0.text = "효율적인 옷장 관리를 위한 스마트 요약!"
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = UIColor(named: "mainBrowm800")
    }
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor(named: "textGray200")
        layer.cornerRadius = 20
        addSubview(bannerImage)
        addSubview(bannerTitle)
        addSubview(bannerDescription)
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        bannerImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(3)
            make.trailing.equalToSuperview().offset(-32)
            make.height.equalTo(78)
            make.width.equalTo(58)
        }
        
        bannerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(23)
            make.leading.equalToSuperview().offset(33)
            make.height.equalTo(20)
        }
        
        bannerDescription.snp.makeConstraints { make in
            make.top.equalTo(bannerTitle.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(33)
            make.height.equalTo(20)
        }
        
    }
}
