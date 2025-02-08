import UIKit
import SnapKit
import Then

class LastAddView: UIView {

    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "back_icon"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
    }

    let titleLabel = UILabel().then {
        $0.text = "옷 추가"
        $0.font = UIFont.ptdRegularFont(ofSize: 20)
        $0.textColor = .black
    }
    
    let addClothLabel = UILabel().then {
        $0.text = "옷 사진을 추가해주세요."
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 24)
        $0.textColor = .black
        $0.textAlignment = .left
    }
    
    let imageView = UIImageView().then {
        $0.image = UIImage(named: "beforeaddimage")
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    let addButton = UIButton().then {
        $0.setImage(UIImage(named: "plus_image"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
    }
    let brandLabel = UILabel().then {
        $0.text = "브랜드를 입력해주세요 (선택)"
        $0.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.textColor = .black
        $0.textAlignment = .left
    }
    
    let brandTextField = UITextField().then {
        $0.placeholder = "예) 아디다스, 슈프림"
        $0.font = UIFont.ptdRegularFont(ofSize: 18)
//        $0.textColor = UIColor(named: "textGray400")
        $0.textColor = UIColor(named: "black")
        $0.borderStyle = .none
    }
    
    let brandUnderline = UIView().then {
        $0.backgroundColor = UIColor(named: "mainBrown600")
    }
    
    let urlLabel = UILabel().then {
        $0.text = "상품 정보 URL을 입력해주세요 (선택)"
        $0.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.textColor = .black
        $0.textAlignment = .left
    }
    
    let urlTextField = UITextField().then {
        $0.placeholder = "http://www.clokey.com/"
        $0.font = UIFont.ptdRegularFont(ofSize: 18)
//        $0.textColor = UIColor(named: "textGray400")
        $0.textColor = UIColor(named: "black")
        $0.borderStyle = .none
    }
    
    let urlUnderline = UIView().then {
        $0.backgroundColor = UIColor(named: "mainBrown600")
    }
    
    let endButton = UIButton().then {
        $0.setTitle("추가하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 10
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(addClothLabel)
        
        addSubview(imageView)
        addSubview(addButton)
        addSubview(brandLabel)
        addSubview(brandTextField)
        addSubview(brandUnderline)
        
        addSubview(urlLabel)
        addSubview(urlTextField)
        addSubview(urlUnderline)
        
        addSubview(endButton)
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        
        backButton.snp.makeConstraints {
            $0.top.leading.equalTo(safeAreaLayoutGuide).inset(20)
            $0.size.equalTo(CGSize(width: 10, height: 20))
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.centerX.equalToSuperview()
        }
        addClothLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(33)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(45)
            make.width.equalTo(346)
        }
        imageView.snp.makeConstraints { make in
            make.top.equalTo(addClothLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(187)
        }
        
        addButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(addClothLabel.snp.bottom).offset(96)
            make.width.height.equalTo(35)
        }
        
        brandLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(35)
            make.leading.equalToSuperview().offset(24)
            make.width.equalTo(243)
            make.height.equalTo(44)
        }
        
        brandTextField.snp.makeConstraints { make in
            make.top.equalTo(brandLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(21)
        }
        
        brandUnderline.snp.makeConstraints { make in
            make.top.equalTo(brandTextField.snp.bottom).offset(6)
            make.leading.trailing.equalTo(brandTextField)
            make.height.equalTo(1)
        }
        
        urlLabel.snp.makeConstraints { make in
            make.top.equalTo(brandUnderline.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(300)
            make.height.equalTo(44)
        }
        
        urlTextField.snp.makeConstraints { make in
            make.top.equalTo(urlLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(21)
        }
        
        urlUnderline.snp.makeConstraints { make in
            make.top.equalTo(urlTextField.snp.bottom).offset(6)
            make.leading.trailing.equalTo(urlTextField)
            make.height.equalTo(1)
        }
        
        endButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(20) // ✅ 좌우 마진 유지
            $0.height.equalTo(54) // 중앙 정렬
            
        }
    }
    
}
