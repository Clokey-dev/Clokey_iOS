import UIKit
import SnapKit
import Then

class CustomTotalSegmentView: UIView {
    
    // MARK: - Subviews
    let menuButton = UIButton().then {
        $0.setImage(UIImage(named: "side_bar"), for: .normal)
        $0.tintColor = .black
        $0.imageView?.contentMode = .scaleAspectFit
    }
    let segmentedControl: UISegmentedControl

    let divideLine = UIView().then {
        $0.backgroundColor = UIColor(named: "mainBrown600")
    }
    
    let indicatorBar = UIView().then {
        $0.backgroundColor = UIColor(named: "mainBrown800")
    }
    //스크롤되는 view로 감싸기 위해
    let categoryScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceHorizontal = true
    }
    //카테고리 버튼들 (categoryScrollView로 감싸져있음)
    internal let categoryButtonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.alignment = .center
        $0.spacing = 8
    }

    // MARK: - Initializer
    init(items: [String]) {
        self.segmentedControl = UISegmentedControl(items: items).then {
            $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
            $0.setBackgroundImage(UIImage(), for: .selected, barMetrics: .default)
            $0.setBackgroundImage(UIImage(), for: .highlighted, barMetrics: .default)
            $0.setDividerImage(UIImage(), forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
            $0.selectedSegmentIndex = 0
            $0.setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor: UIColor.black,
                .font: UIFont.ptdLightFont(ofSize: 18)
            ], for: .normal)
            $0.setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor: UIColor.black,
                .font: UIFont.ptdBoldFont(ofSize: 18)
            ], for: .selected)
            $0.apportionsSegmentWidthsByContent = false
        }
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        addSubview(menuButton)
        addSubview(segmentedControl)
        addSubview(divideLine)
        addSubview(indicatorBar)
        addSubview(categoryScrollView)
        categoryScrollView.addSubview(categoryButtonStackView)
    }
    
    private func setupConstraints() {
        menuButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.width.equalTo(24)
        }
        
        segmentedControl.snp.makeConstraints {
            $0.bottom.equalTo(menuButton.snp.bottom)
            $0.leading.equalTo(menuButton.snp.trailing).offset(18)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        divideLine.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.leading.equalTo(menuButton.snp.trailing).offset(24)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        indicatorBar.snp.makeConstraints {
            $0.width.equalTo(44)
            $0.height.equalTo(3)
            $0.bottom.equalTo(segmentedControl.snp.bottom).offset(2)
            $0.leading.equalTo(divideLine.snp.leading)
        }
        
        categoryScrollView.snp.makeConstraints {
            $0.top.equalTo(divideLine.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(49)
        }
        
        categoryButtonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(29)
            $0.top.equalTo(categoryScrollView.snp.top).offset(10)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustSegmentWidths() // 정확한 레이아웃 이후 호출
    }
    //다른 세그먼트들은 (상의, 기타, 전체, 하의) 2글자인데, 아우터는 3글자임 그 pt 차이가 15여서 index == 3을 15만큼 더 길이를 늘림
    private func adjustSegmentWidths() {
        let totalWidth = frame.width - 40 // CustomTotalSegmentView의 leading 간격 반영
        let additionalWidth: CGFloat = 15 // 추가 너비
        let baseWidth = (totalWidth - additionalWidth) / 5 // 기본 세그먼트 너비

        for index in 0..<segmentedControl.numberOfSegments {
            if index == 3 { // 4번째 세그먼트
                segmentedControl.setWidth(baseWidth + additionalWidth, forSegmentAt: index)
            } else {
                segmentedControl.setWidth(baseWidth, forSegmentAt: index)
            }
        }
    }


    //indicatorBar 위치 설정해주는 logic (이건 제가 그냥 계산때려서 한거라 혹시 궁금하면 질문해주세요...)
    // MARK: - Public Methods
    func updateIndicatorPosition(for index: Int) {
        guard frame.width > 0 else { return }

        let totalWidth = frame.width - 40
        let additionalWidth: CGFloat = 15
        let baseWidth = (totalWidth - additionalWidth) / 5

        var cumulativeWidth: CGFloat = 0
        for i in 0..<index {
            cumulativeWidth += (i == 3) ? (baseWidth + additionalWidth) : baseWidth
        }

        let selectedSegmentWidth = (index == 3) ? (baseWidth + additionalWidth) : baseWidth
        let indicatorBarLeading = cumulativeWidth + (selectedSegmentWidth / 2) - 23 // Indicator 중심 계산

        UIView.animate(withDuration: 0.3) {
            self.indicatorBar.snp.remakeConstraints {
                $0.leading.equalTo(self.segmentedControl.snp.leading).offset(indicatorBarLeading)
                $0.width.equalTo(44)
                $0.height.equalTo(3)
                $0.bottom.equalTo(self.segmentedControl.snp.bottom).offset(2)
            }
            self.layoutIfNeeded()
        }
    }

    //(각세그먼트 눌렀을때 기존 카테고리 버튼은 초기화하고 새로운 세그먼트에 맞는 버튼을 띄움)
    func updateCategories(for categories: [String]) {
        // 기존 버튼 제거
        categoryButtonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        categories.forEach { category in
            let button = UIButton().then {
                var configuration = UIButton.Configuration.filled()
                
                // 타이틀 설정
                configuration.title = category
                configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = UIFont.ptdRegularFont(ofSize: 16)
                    return outgoing
                }
                
                // UI 속성 설정
                configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 14, bottom: 5, trailing: 14)
                configuration.baseBackgroundColor = .white
                configuration.baseForegroundColor = .black

                // 버튼 적용
                $0.configuration = configuration
                $0.layer.borderColor = UIColor(named: "pointOrange800")?.cgColor
                $0.layer.borderWidth = 1.0
                $0.layer.cornerRadius = 15
                $0.clipsToBounds = true
            }
            
            // StackView에 추가
            categoryButtonStackView.addArrangedSubview(button)
            
        }


        let totalWidth = categoryButtonStackView.arrangedSubviews.reduce(0) { $0 + $1.intrinsicContentSize.width + 16 }
        categoryScrollView.contentSize = CGSize(width: totalWidth, height: categoryScrollView.frame.height)
    }
    //"전체" 세그먼트는 button이 없어서 이걸로 그걸 조정해줍니다. 저 같은 경우엔 "전체"일 때는 세그먼트아래에 바로 collectionView가 뜨게해야해서 이건 ViewController에 해뒀어요.
    func toggleCategoryButtons(isHidden: Bool) {
        categoryScrollView.isHidden = isHidden
    }
}
