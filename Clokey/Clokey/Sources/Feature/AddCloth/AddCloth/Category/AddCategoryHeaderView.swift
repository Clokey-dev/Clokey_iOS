import UIKit
import SnapKit
import Then

class AddCategoryHeaderView: UICollectionReusableView {
    
    static let identifier = "AddCategoryHeaderView"

    let categoryLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.ptdRegularFont(ofSize: 20)
    }

    let divideLine = UIView().then {
        $0.backgroundColor = UIColor(named: "mainBrown800")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.snp.makeConstraints {
//            $0.height.equalTo(27)
//        }
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(categoryLabel)
        addSubview(divideLine)

        categoryLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(26)
        }

        divideLine.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func configure(with title: String) {
        categoryLabel.text = title
    }
}
