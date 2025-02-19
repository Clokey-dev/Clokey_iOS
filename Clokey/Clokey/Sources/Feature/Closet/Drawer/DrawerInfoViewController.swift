import UIKit

class DrawerInfoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Properties
    
    /// 선택된 옷 목록 (서버에 이미 등록된 옷이므로 clothIds만 전달)
    private var products: [ClosetModel] = []
    
    /// 기존 폴더 ID (수정 시 사용); 새 폴더 생성 시에는 nil
    private var existingFolderId: Int64?
    
    /// 폴더 생성/수정 API 호출 시 사용할 Service
    private let folderService = FolderService()
    
    // API 서비스 (옷 데이터)
    private let clothesService = ClothesService()
    
    // MARK: - UI
    
    /// "완료" 버튼 (폴더 생성/수정 API 호출)
    private lazy var createButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(createButtonTapped))
        button.isEnabled = false
        button.tintColor = .clear
        return button
    }()
    
    /// 커스텀 뷰 DrawerInfoView (폴더명 입력 텍스트필드, CollectionView 포함)
    var drawerInfoView: DrawerInfoView {
        return view as! DrawerInfoView
    }
    
    // MARK: - Initializers
    
    /// - Parameters:
    ///   - folderId: 편집 시 폴더 ID, 새 폴더 생성 시에는 nil
    ///   - selectedClothes: 이전 화면에서 전달받은 옷 목록 (DrawerEditViewController 등)
    init(folderId: Int64? = nil, selectedClothes: [ClosetModel] = []) {
        self.existingFolderId = folderId
        self.products = selectedClothes
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = DrawerInfoView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("existingFolderId: \(existingFolderId ?? -1)")
        
        setupUI()
        setupCollectionView()
        setupActions()
        
        // (예시) API를 통해 옷 데이터를 추가로 불러와 products를 갱신
        // 만약 이전 화면에서 받은 selectedClothes만 표시하려면 이 호출을 생략하세요.
        loadClothesData()
        
        // 폴더 생성 vs 수정에 따라 네비게이션 타이틀 설정
        if let folderId = existingFolderId, folderId != 0 {
            navigationItem.title = "서랍 수정"
        } else {
            navigationItem.title = "서랍 생성"
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = createButton
        
        let navBarManager = NavigationBarManager()
        navBarManager.addBackButton(to: navigationItem, target: self, action: #selector(backButtonTapped))
        navBarManager.setTitle(
            to: navigationItem,
            title: (existingFolderId == nil || existingFolderId == 0) ? "서랍 생성" : "서랍 수정",
            font: .ptdBoldFont(ofSize: 20),
            textColor: .black
        )
        
        drawerInfoView.folderTextField.placeholder = "폴더명을 입력하세요"
    }
    
    private func setupCollectionView() {
        let collectionView = drawerInfoView.collectionView
        // **여기서 프로토콜 채택** (중요)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            ClosetCollectionViewCell.self,
            forCellWithReuseIdentifier: ClosetCollectionViewCell.identifier
        )
    }
    
    private func setupActions() {
        drawerInfoView.folderTextField.addTarget(self, action: #selector(folderTextFieldChanged(_:)), for: .editingChanged)
    }
    
    // MARK: - Actions
    
    @objc private func folderTextFieldChanged(_ textField: UITextField) {
        let text = textField.text ?? ""
        let isFilled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        createButton.isEnabled = isFilled
        createButton.tintColor = isFilled ? .black : .clear
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 폴더 생성/수정 API 호출 및 DrawerViewController로 전환
    @objc private func createButtonTapped() {
        // 1) 폴더명 추출
        let folderName = drawerInfoView.folderTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "새 폴더"
        
        // 2) 현재 products 배열에 있는 옷들의 id 추출 (서버에 등록된 옷이므로 clothIds로 전달)
        let clothIds = products.map { Int64($0.id) }
        
        // 3) 새 폴더 생성 vs 수정 분기
        let idVal = existingFolderId ?? 0
        let folderIdForRequest: Int64? = (idVal == 0) ? nil : idVal
        
        let requestDTO = FolderManageRequestDTO(
            folderId: folderIdForRequest,  // nil이면 JSON에서 folderId 키 생략됨
            folderName: folderName,
            clothIds: clothIds
        )
        
        // 4) API 호출
        folderService.folderManage(data: requestDTO) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseDTO):
                    print("폴더 생성/수정 성공: folderId = \(responseDTO.folderId)")
                    // 5) API 응답으로 받은 folderId를 DrawerItem에 반영하여 DrawerViewController로 전환
                    let newDrawerItem = DrawerModel(
                        id: responseDTO.folderId,
                        title: folderName,
                        imageUrl: "",  // 이미지 URL이 없는 경우 빈 문자열
                        itemCountText: "\(clothIds.count) 개"
                    )
                    let drawerVC = DrawerViewController(drawerItem: newDrawerItem)
                    self?.navigationController?.pushViewController(drawerVC, animated: true)
                    
                case .failure(let error):
                    self?.showErrorAlert(error)
                }
            }
        }
    }
    
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(title: "오류", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - API Data Loading
    
    /// clothesService를 통해 옷 데이터를 불러와 products에 저장합니다.
    private func loadClothesData(categoryId: Int = 1, season: String = "ALL") {
        clothesService.getClothes(
            clokeyId: nil,
            categoryId: categoryId,
            season: season,
            sort: "",     // 정렬 기능 없이 빈 문자열 전달
            page: 1,      // 항상 첫 페이지
            size: 6       // 필요에 따라 표시할 cell 개수 (예시)
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let newItems = response.clothPreviews.map { preview in
                    ClosetModel(
                        id: preview.id,
                        image: preview.imageUrl,
                        count: preview.wearNum,
                        name: preview.name
                    )
                }
                
                // 현재는 서버에서 받은 데이터로 products를 덮어씀
                // 만약 기존 selectedClothes + 서버 데이터 병합이 필요하다면, 여기서 merge 로직 추가
                self.products = newItems
                
                DispatchQueue.main.async {
                    self.drawerInfoView.collectionView.reloadData()
                }
            case .failure(let error):
                print("Error loading clothes: \(error)")
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    
    // 표시할 아이템 수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    // 각 셀 구성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ClosetCollectionViewCell.identifier,
            for: indexPath
        ) as? ClosetCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let product = products[indexPath.item]
        // ClosetCollectionViewCell에 맞춰 이미지를 로드하고, 라벨 설정
        cell.configureCell(with: product, hideNumberLabel: true, hideCountLabel: true)
        
        return cell
    }
    
    // (옵션) 셀 탭 시 추가 액션이 필요하다면 구현
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 현재 화면에서는 선택/해제 로직이 없으므로 비워둠
    }
}
