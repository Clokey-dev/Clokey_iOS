import UIKit
import SnapKit
import Kingfisher

class LikeHistoryCell: UICollectionViewCell {
    
    static let identifier = "LikeHistoryCell"
    
    // 이미지 뷰만 남겨서 타이틀은 표시하지 않음
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Kingfisher를 사용해 URL 이미지 로드 (타이틀은 필요 없으므로 단일 파라미터)
    func configure(with imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }
}
