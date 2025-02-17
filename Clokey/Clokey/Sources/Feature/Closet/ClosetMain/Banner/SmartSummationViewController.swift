//import UIKit
//
//class SmartSummationViewController: UIViewController {
//
//    // 스마트 요약 뷰와 서비스 인스턴스
//    private let summationView = SmartSummationView()
//    private let clothesService = ClothesService()
//    
//    // API 응답으로 받아온 옷 목록 데이터
//    private var frequentClothes: [ClothPreviewDTO] = []
//    private var infrequentClothes: [ClothPreviewDTO] = []
//    
//    override func loadView() {
//        // 커스텀 뷰를 루트뷰로 설정
//        self.view = summationView
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionViews()
//        fetchSmartSummationData()
//    }
//    
//    private func setupCollectionViews() {
//        summationView.freCollectionView.dataSource = self
//        summationView.freCollectionView.delegate = self
//        summationView.infreCollectionView.dataSource = self
//        summationView.infreCollectionView.delegate = self
//    }
//    
//    private func fetchSmartSummationData() {
//        // 스마트 요약 API 호출
//        clothesService.getSmartSummationClothes { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let response):
//                if response.isSuccess {
//                    // API 응답 데이터에서 자주/잘 안 입은 옷 결과 추출
//                    let frequent = response.result.frequentResult
//                    let infrequent = response.result.infrequentResult
//                    
//                    DispatchQueue.main.async {
//                        // 첫 번째 라인 업데이트 (자주 입은 옷)
//                        self.summationView.categoryButton1.setTitle(frequent.baseCategoryName, for: .normal)
//                        self.summationView.categoryButton2.setTitle(frequent.coreCategoryName, for: .normal)
//                        self.summationView.frequentTitleLabel.text = " - 일주일간 평균 \(frequent.usage)회 착용"
//                        self.frequentClothes = frequent.clothPreviews
//                        self.summationView.freCollectionView.reloadData()
//                        
//                        // 두 번째 라인 업데이트 (잘 안 입은 옷)
//                        self.summationView.categoryButton3.setTitle(infrequent.baseCategoryName, for: .normal)
//                        self.summationView.categoryButton4.setTitle(infrequent.coreCategoryName, for: .normal)
//                        self.summationView.infrequentTitleLabel.text = " - 일주일간 평균 \(infrequent.usage)회 착용"
//                        self.infrequentClothes = infrequent.clothPreviews
//                        self.summationView.infreCollectionView.reloadData()
//                    }
//                }
//            case .failure(let error):
//                print("스마트 요약 API 호출 실패: \(error)")
//            }
//        }
//    }
//}
//
//// MARK: - UICollectionViewDataSource & Delegate
//
//extension SmartSummationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    // 두 컬렉션 뷰 모두 1개의 섹션을 사용
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == summationView.freCollectionView {
//            return frequentClothes.count
//        } else {
//            return infrequentClothes.count
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as? CustomCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//        
//        let cloth: ClothPreviewDTO
//        if collectionView == summationView.freCollectionView {
//            cloth = frequentClothes[indexPath.item]
//        } else {
//            cloth = infrequentClothes[indexPath.item]
//        }
//        
//        // CustomCollectionViewCell 내부에서 cloth 데이터를 활용해 UI 업데이트
//        cell.configure(with: cloth)
//        return cell
//    }
//    
//    // 셀 크기 설정 (FlowLayout 활용)
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        // SmartSummationView에서 설정한 estimatedItemSize와 일치시키거나, 원하는 크기를 반환합니다.
//        return CGSize(width: 111, height: 167)
//    }
//}






// 더미테이터 버전
//import UIKit
//
//class SmartSummationViewController: UIViewController {
//
//    // 스마트 요약 뷰와 더미 데이터를 저장할 배열들
//    private let summationView = SmartSummationView()
//    private var frequentClothes: [ClothPreviewDTO] = []
//    private var infrequentClothes: [ClothPreviewDTO] = []
//    
//    override func loadView() {
//        self.view = summationView
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionViews()
//        loadDummyData()
//
//    }
//    
//    private func setupUI() {
//        let navBarManager = NavigationBarManager()
//        navBarManager.addBackButton(
//            to: navigationItem,
//            target: self,
//            action: #selector(backButtonTapped)
//        )
//        
//        navBarManager.setTitle(
//            to: navigationItem,
//            title: "스마트요약",
//            font: .ptdBoldFont(ofSize: 20),
//            textColor: .black
//        )
//    }
//
//    
//    private func setupCollectionViews() {
//        summationView.freCollectionView.dataSource = self
//        summationView.freCollectionView.delegate = self
//        summationView.infreCollectionView.dataSource = self
//        summationView.infreCollectionView.delegate = self
//    }
//    
//    private func loadDummyData() {
//        // 자주 입은 옷 더미 데이터 생성
//        let dummyFrequentCloth1 = ClothPreviewDTO(id: 1, name: "Frequent Cloth 1", imageUrl: "dummyImage1", wearNum: 5)
//        let dummyFrequentCloth2 = ClothPreviewDTO(id: 2, name: "Frequent Cloth 2", imageUrl: "dummyImage2", wearNum: 4)
//        let dummyFrequentCloth3 = ClothPreviewDTO(id: 3, name: "Frequent Cloth 3", imageUrl: "dummyImage3", wearNum: 3)
//        let dummyFrequent = SummaryClothPreviewDTO(
//            baseCategoryName: "상의",
//            coreCategoryName: "셔츠",
//            usage: 4,
//            clothPreviews: [dummyFrequentCloth1, dummyFrequentCloth2, dummyFrequentCloth3]
//        )
//        
//        // 잘 안 입은 옷 더미 데이터 생성
//        let dummyInfrequentCloth1 = ClothPreviewDTO(id: 4, name: "Infrequent Cloth 1", imageUrl: "dummyImage4", wearNum: 1)
//        let dummyInfrequentCloth2 = ClothPreviewDTO(id: 5, name: "Infrequent Cloth 2", imageUrl: "dummyImage5", wearNum: 2)
//        let dummyInfrequent = SummaryClothPreviewDTO(
//            baseCategoryName: "하의",
//            coreCategoryName: "바지",
//            usage: 1,
//            clothPreviews: [dummyInfrequentCloth1, dummyInfrequentCloth2]
//        )
//        
//        // UI에 더미 데이터 바인딩 (첫 번째 라인: 자주 입은 옷)
//        summationView.categoryButton1.setTitle(dummyFrequent.baseCategoryName, for: .normal)
//        summationView.categoryButton2.setTitle(dummyFrequent.coreCategoryName, for: .normal)
//        summationView.frequentTitleLabel.text = " - 일주일간 평균 \(dummyFrequent.usage)회 착용"
//        frequentClothes = dummyFrequent.clothPreviews
//        
//        // 두 번째 라인: 잘 안 입은 옷
//        summationView.categoryButton3.setTitle(dummyInfrequent.baseCategoryName, for: .normal)
//        summationView.categoryButton4.setTitle(dummyInfrequent.coreCategoryName, for: .normal)
//        summationView.infrequentTitleLabel.text = " - 일주일간 평균 \(dummyInfrequent.usage)회 착용"
//        infrequentClothes = dummyInfrequent.clothPreviews
//        
//        // 컬렉션 뷰 업데이트
//        summationView.freCollectionView.reloadData()
//        summationView.infreCollectionView.reloadData()
//    }
//}
//
//// MARK: - UICollectionViewDataSource & DelegateFlowLayout
//
//extension SmartSummationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == summationView.freCollectionView {
//            return frequentClothes.count
//        } else {
//            return infrequentClothes.count
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as? CustomCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//        
//        let cloth: ClothPreviewDTO = collectionView == summationView.freCollectionView ? frequentClothes[indexPath.item] : infrequentClothes[indexPath.item]
//        
//        // 직접 cell의 UI 요소에 데이터를 할당 (configure 메서드 없이)
//        cell.productImageView.image = UIImage(named: cloth.imageUrl)
//        cell.numberLabel.text = "\(cloth.id)"
//        cell.countLabel.text = "\(cloth.wearNum)회"
//        cell.nameLabel.text = cloth.name
//        
//        return cell
//    }
//    
//    // 셀 크기 설정
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 111, height: 167)
//    }
//    
//    @objc private func backButtonTapped() {
//        navigationController?.popViewController(animated: true)
//    }
//}
