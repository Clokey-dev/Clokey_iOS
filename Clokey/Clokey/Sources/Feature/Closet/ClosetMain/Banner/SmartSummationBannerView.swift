import UIKit
import SnapKit
import Then

class SmartSummationBannerView: UIView {
    
    // MARK: - UI Component
    
    private let bannerImage = UIImageView().then {
        $0.image = UIImage(named: "bannerimage")
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
        $0.textColor = .black
    }
    
    private let bannerButton = UIButton().then {
        $0.setTitle("스마트 요약 확인하기", for: .normal)
        $0.backgroundColor = UIColor(named: "pointOrange800")
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 11)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
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
        backgroundColor = UIColor(named: "pointOrange400")
        layer.cornerRadius = 20
        addSubview(bannerImage)
        addSubview(bannerTitle)
        addSubview(bannerDescription)
        addSubview(bannerButton) // ✅ bannerView 안에 넣도록 변경
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        bannerImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(75)
        }
        
        bannerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(bannerImage.snp.trailing).offset(8)
        }
        
        bannerDescription.snp.makeConstraints { make in
            make.top.equalTo(bannerTitle.snp.bottom).offset(5)
            make.leading.equalTo(bannerTitle.snp.leading)
        }
        
        bannerButton.snp.makeConstraints { make in
            make.top.equalTo(bannerDescription.snp.bottom).offset(4)
            make.leading.equalTo(bannerTitle.snp.leading)
            make.width.equalTo(104)
            make.height.equalTo(22)
        }
    }
}
