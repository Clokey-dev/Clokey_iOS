import UIKit

class DrawerCollectionViewCell: UICollectionViewCell {
    static let identifier = "DrawerCollectionViewCell"
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true  // 내부 요소만 둥글게
    }
    
    // 상품 이미지
    let productImageView = UIImageView().then{
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
    }
    
    // 폴더명
    let folderLabel = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    // 속한 아이템 수 라벨
    let itemCountLabel = UILabel().then {
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    
    // MARK: - Setup
    func setupViews() {
        // 셀의 콘텐츠 뷰에 추가
        contentView.addSubview(containerView)
        containerView.addSubview(productImageView)
        containerView.addSubview(folderLabel)
        containerView.addSubview(itemCountLabel)
        contentView.layer.masksToBounds = false //그림자를 보이게 하기 위해
        
        // Auto Layout 설정
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(1) // 테두리 그림자 여백 확보
        }
        
        productImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.width.equalTo(77)
        }
        
        folderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)//레이아웃이 넓어서 확인해야함
            $0.leading.equalTo(productImageView.snp.trailing).offset(9)
        }
        
        itemCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(37)//레이아웃이 넓어서 확인해야함
            $0.leading.equalTo(productImageView.snp.trailing).offset(9)
        }
        
        setupShadow()
    }
    private func setupShadow() {
        layer.cornerRadius = 10  // radius 동잃하게 설정
        layer.masksToBounds = false  // 그림자가 잘리지 않도록 설정
        layer.shadowColor = UIColor.black.cgColor  // 그림자 색상
        layer.shadowOpacity = 0.2 //그림자 투명도
        layer.shadowRadius = 2  //그림자 블러
        layer.shadowOffset = CGSize(width: 0, height: 0)  // .zero로 해도 됩니다.
    }
    
    override func layoutSubviews() {
            super.layoutSubviews()
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        }


}

