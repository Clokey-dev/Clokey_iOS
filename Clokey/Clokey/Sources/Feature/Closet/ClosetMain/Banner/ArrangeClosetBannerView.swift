import UIKit

class ArrangeClosetBannerView: UIControl {

    
    let bannerImage = UIImageView().then {
        $0.image = UIImage(named: "bannerimage2")
        $0.contentMode = .scaleAspectFit
    }
    
    let bannerTitle = UILabel().then {
        $0.text = "봄이 오기 전, 옷장도 준비 완료!"
        $0.font = UIFont.ptdBoldFont(ofSize: 16)
        $0.textColor = UIColor(named: "mainBrown800")
    }
    
    let bannerDescription = UILabel().then {
        $0.text = "옷장 속 계절 바꾸기, 지금이 딱 좋은 타이밍"
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = UIColor(named: "mainBrown800")
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
        backgroundColor = UIColor(named: "textGray200")
        layer.cornerRadius = 20
        addSubview(bannerImage)
        addSubview(bannerTitle)
        addSubview(bannerDescription)
    }

    private func setupConstraints() {
        bannerImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-23)
            make.height.equalTo(65)
            make.width.equalTo(69)
        }
        
        bannerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(23)
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(20)
        }
        
        bannerDescription.snp.makeConstraints { make in
            make.top.equalTo(bannerTitle.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(33)
            make.height.equalTo(20)
        }
    }
}
