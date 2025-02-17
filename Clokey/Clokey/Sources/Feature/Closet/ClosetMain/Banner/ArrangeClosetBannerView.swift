import UIKit

class ArrangeClosetBannerView: UIView {

    
    let bannerImage = UIImageView().then {
        $0.image = UIImage(named: "bannerimage2")
        $0.contentMode = .scaleAspectFit
    }
    
    let bannerTitle = UILabel().then {
        $0.text = "겨울이 오기 전, 옷장도 준비 완료!"
        $0.font = UIFont.ptdBoldFont(ofSize: 16)
        $0.textColor = UIColor(named: "mainBrown800")
    }
    
    let bannerDescription = UILabel().then {
        $0.text = "옷장 속 계절 바꾸기, 지금이 딱 좋은 타이밍"
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .black
    }
    
    let bannerButton = UIButton().then {
        $0.setTitle("옷장 정리하러 가기", for: .normal)
        $0.backgroundColor = UIColor(named: "pointOrange800")
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 11)
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
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

    
    private func setupUI() {
        backgroundColor = UIColor(named: "mainBrown50")
        layer.cornerRadius = 20
        addSubview(bannerImage)
        addSubview(bannerTitle)
        addSubview(bannerDescription)
        addSubview(bannerButton)
    }

    private func setupConstraints() {
        bannerImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(7)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(80)
        }
        
        bannerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(bannerImage.snp.trailing).offset(9)
        }
        
        bannerDescription.snp.makeConstraints { make in
            make.top.equalTo(bannerTitle.snp.bottom).offset(5)
            make.leading.equalTo(bannerTitle.snp.leading)
        }
        
        bannerButton.snp.makeConstraints { make in
            make.top.equalTo(bannerDescription.snp.bottom).offset(5) // 이부분 질문
            make.leading.equalTo(bannerTitle.snp.leading)
            make.width.equalTo(104)
            make.height.equalTo(22)
        }
    }
}
