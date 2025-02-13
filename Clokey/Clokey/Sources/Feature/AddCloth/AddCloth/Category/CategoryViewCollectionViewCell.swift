
import UIKit
import SnapKit
import Then

class CategoryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "AddCategoryCollectionViewCell"
    

    let categoryButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 13, bottom: 4, trailing: 13) // 내부 여백
        let font = UIFont.systemFont(ofSize: 16)// 원하는 글씨체와 크기 설정
        var titleAttr = AttributedString("티셔츠") // 기본 텍스트
        titleAttr.font = font
        config.attributedTitle = titleAttr

        $0.configuration = config
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown800")!.cgColor
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(categoryButton)
        
        categoryButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(32)
        }
    }
    
    func configure(with title: String) {
        categoryButton.setTitle(title, for: .normal)
    }
}

extension CategoryCollectionViewCell {
    func updateAppearance(isSelected: Bool) {
        if isSelected {
            categoryButton.backgroundColor = UIColor(named: "mainBrown800") // 브라운 배경색
            categoryButton.setTitleColor(.white, for: .normal) // 흰색 텍스트
        } else {
            categoryButton.backgroundColor = .clear // 기본 배경색
            categoryButton.setTitleColor(.black, for: .normal) // 기본 텍스트 색상
        }
    }
}
