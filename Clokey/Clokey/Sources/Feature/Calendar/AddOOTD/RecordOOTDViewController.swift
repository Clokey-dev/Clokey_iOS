//
//  RecordOOTDViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/20/25.
//

import UIKit
import Kingfisher

class RecordOOTDViewController: UIViewController {
    
    // MARK: - Properties

    let historyService = HistoryService()
    
    // 기록 작성 리스트 변수들
    private var hashtags: [String] = []
    private var selectedImages: [UIImage] = []
    private var taggedItems: [(id: Int, image: UIImage, title: String)] = []
    private var contentText: String = ""
    private var isPublic: Bool = true
    private var selectedDate: Date?
        
    func setDate(_ date: Date) {
        self.selectedDate = date
    }
    
    private let mainView = RecordOOTDView()
    private let navBarManager = NavigationBarManager()
    
    weak var delegate: RecordOOTDViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        setupActions()
        setupKeyboardHandling()
        updateCollectionViewHeight(false)
        
        mainView.contentInputView.delegate = self
    }
    
    // MARK: - Setup
    // 네비게이션 설정
    private func setupNavigationBar() {
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(didTapBackButton)
        )
        
        navBarManager.setTitle(
            to: navigationItem,
            title: "캘린더에 기록하기",
            font: .systemFont(ofSize: 18, weight: .semibold),
            textColor: .black
        )
    }
    
    // RecordOOTDView 데이터소스&델리게이트 설정
    private func setupCollectionView() {
        mainView.photoTagView.imageCollectionView.dataSource = self
        mainView.photoTagView.tagCollectionView.dataSource = self
        mainView.photoTagView.tagCollectionView.delegate = self
    }
    
    // 버튼 이벤트 설정
    private func setupActions() {
        
        // 사진 버튼
        let imageSelectTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSelectImage))
        mainView.photoTagView.selectImageStack.addGestureRecognizer(imageSelectTapGesture)
        
        // 태그하기 버튼
        let tagSelectTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTagSelect))
        mainView.photoTagView.tagImageStack.addGestureRecognizer(tagSelectTapGesture)
        
        mainView.OOTDButton.addTarget(
            self,
            action: #selector(didTapOOTDButton),
            for: .touchUpInside
        )
    }
    
    // 키보드 내리기
    private func setupKeyboardHandling() {
        // 키보드 dismiss를 위한 탭 제스처
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // 설정된 해시태그에 따라 컬렉션 뷰의 높이 설정
    private func updateCollectionViewHeight(_ hasImages: Bool) {
        mainView.updateCollectionViewHeight(hasImages)
    }
    
    // 수정할 기록 데이터 불러오기
    func setEditData(_ viewModel: CalendarDetailViewModel) {
        self.contentText = viewModel.content
        self.selectedDate = convertStringToDate(viewModel.date)

        // 내용 설정
        mainView.contentInputView.textAddBox.text = viewModel.content
        mainView.contentInputView.textAddBox.textColor = viewModel.content.isEmpty ? .placeholderText : .black

        // 해시태그 설정
        let hashtagsArray = viewModel.hashtags.components(separatedBy: "#")
            .filter { !$0.isEmpty } // 빈 문자열 제거
            .map { "#\($0)" } // "#"을 다시 붙여 원본 형태 복원

        hashtagsArray.forEach { tag in
            self.hashtags.append(tag)
            mainView.contentInputView.addHashtag(tag)
        }
        
        // 공개 여부 설정
        mainView.contentInputView.publicButton.isSelected = viewModel.visibility
        mainView.contentInputView.privateButton.isSelected = !viewModel.visibility

        // 이미지 및 태그한 옷 설정 (비동기 로드)
        loadImages(from: viewModel.images)
        loadTaggedClothes(from: viewModel.cloths)
    }

    
    // MARK: - Actions
    // 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    // CustomGalleryViewController로 네비게이션
    @objc private func didTapSelectImage() {
        let galleryVC = CustomGalleryViewController()
        galleryVC.delegate = self
        let navVC = UINavigationController(rootViewController: galleryVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    // 태그 선택 네비게이션
    @objc private func didTapTagSelect() {
        let tagClothVC = TagClothViewController()
        tagClothVC.delegate = self
        let navVC = UINavigationController(rootViewController: tagClothVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    // 키보드 내리기
    @objc override func dismissKeyboard() {
        view.endEditing(true) // 편집 상태 종료
    }

    // 기록하기의 확인 버튼
    @objc private func didTapOOTDButton() {
        if mainView.OOTDButton.isEnabled {
            let content = mainView.contentInputView.textAddBox.text ?? ""
            let clothesIds = taggedItems.map { Int64($0.id) }
            let visibility = mainView.contentInputView.publicButton.isSelected ? "PUBLIC" : "PRIVATE"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = selectedDate.map { dateFormatter.string(from: $0) } ?? "2025-02-08"

            let requestDTO = HistoryCreateRequestDTO(
                content: content,
                clothes: clothesIds,
                hashtags: hashtags,
                visibility: visibility,
                date: dateString
            )
            
            // 이미지 압축 및 크기 제한
            let imageDataArray = selectedImages.compactMap { image in
                return image.jpegData(compressionQuality: 1.0)
            }
            
            let historyService = HistoryService()
            historyService.historyCreate(data: requestDTO, images: imageDataArray) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    print("History created successfully with ID: \(response.historyId)")
                    DispatchQueue.main.async {
                        self.delegate?.didUpdateHistory()  // 새로고침
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                case .failure(let error):
                    print("Failed to create history: \(error)")
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension RecordOOTDViewController: UICollectionViewDataSource {
    
    // 반환된 이미지 갯수 체크
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 갤러리에서 불러온 이미지 갯수 카운트
        if collectionView == mainView.photoTagView.imageCollectionView {
            return selectedImages.count
        // 내 옷장에서 선택한 옷 갯수 카운트
        } else if collectionView == mainView.photoTagView.tagCollectionView {
            return taggedItems.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 갤러리 사진 처리
        // ImageCollectionViewCell로 사진 띄우기
        if collectionView == mainView.photoTagView.imageCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ImageCollectionViewCell.identifier,
                for: indexPath
            ) as! ImageCollectionViewCell
            
            cell.configure(with: selectedImages[indexPath.item], isFirstImage: indexPath.item == 0)
            
            cell.deleteButtonTapHandler = { [weak self] in
                guard let self = self else { return }
                self.selectedImages.remove(at: indexPath.item)
                
                // 컬렉션 뷰 상태 완전 초기화
                self.mainView.photoTagView.imageCollectionView.reloadData()
                
                // 이미지가 모두 삭제되었을 때 컬렉션 뷰 상태 리셋
                if self.selectedImages.isEmpty {
                    self.mainView.photoTagView.imageCollectionView.setContentOffset(.zero, animated: true)
                }
                
                self.updateCollectionViewHeight(!self.selectedImages.isEmpty)
            }
            
            return cell
        } else {
            // 내 옷장에서 선택한 옷 처리
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CustomCollectionViewCell.identifier,
                for: indexPath
            ) as! CustomCollectionViewCell
            
            let item = taggedItems[indexPath.item]
            
            // 이미지랑 이름 라벨만 사용
            cell.productImageView.image = item.image
            cell.nameLabel.text = item.title
            
            // 넘버링 라벨을 x 버튼으로 재활용
            cell.numberLabel.isHidden = false
            cell.numberLabel.text = "×"
            cell.numberLabel.font = .systemFont(ofSize: 14, weight: .bold)
            cell.countLabel.isHidden = true
            cell.numberLabel.backgroundColor = .clear
            cell.numberLabel.textColor = .black
            
            // X 버튼 위치 재설정
            cell.numberLabel.snp.remakeConstraints {
                $0.top.equalTo(cell.productImageView).offset(5)
                $0.trailing.equalTo(cell.productImageView).offset(-5)
                $0.width.height.equalTo(20)
            }
            
            cell.isSelectable = false
            cell.setSelected(false)
            
            // X 버튼 기능
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteTagItem(_:)))
            cell.numberLabel.isUserInteractionEnabled = true
            cell.numberLabel.tag = indexPath.item
            cell.numberLabel.addGestureRecognizer(tapGesture)
            
            return cell
        }
    }
}

extension RecordOOTDViewController {
    @objc private func deleteTagItem(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        let index = label.tag
        
        // 해당 인덱스의 아이템 삭제
        taggedItems.remove(at: index)
        mainView.photoTagView.tagCollectionView.reloadData()
        // 아이템 삭제 시, 컬렉션 뷰 높이 값 수정
        mainView.photoTagView.updateTagCollectionViewHeight(!taggedItems.isEmpty)

    }
}

// MARK: - CustomGalleryViewControllerDelegate
// CustomGalleryViewController와 PhotoEditViewController 간의 연결
/*

 왜 바로 연결 안하고 분리해서 작업했을까?
-> CustomGalleryViewController는 이미지를 선택하고 델리게이트를 호출 하는 역할만
-> PhotoEditViewController는 이미지를 편집하고 결과를 델리게이트를 통해 전달하는 역할만 수행

 유사 조정자(Mediator) 패턴의 예시가 될 수 있음..(아마)
-> 객체 간의 상호작용을 중앙에서 관리하여 결합도를 낮추는 디자인 패턴임
-> 즉, 각 컨트롤러는 독립적으로 동작하고 상호작용은 RecordOOTDViewController가 관리하는 구조

*/
extension RecordOOTDViewController: CustomGalleryViewControllerDelegate {
    func galleryViewController(_ viewController: CustomGalleryViewController, didSelect images: [UIImage]) {
        // 이미지를 선택하고 닫기
        viewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            // 해당 이미지들을 PhotoEditViewController에서 열기
            let editVC = PhotoEditViewController()
            editVC.delegate = self
            editVC.configure(with: images)
            
            let navController = UINavigationController(rootViewController: editVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        }
    }
}

// MARK: - PhotoEditViewControllerDelegate
// 이미지 편집 완료 결과 처리
extension RecordOOTDViewController: PhotoEditViewControllerDelegate {
    func photoEditViewController(_ viewController: PhotoEditViewController, didFinishEditing images: [UIImage]) {
        
        selectedImages = images
        mainView.photoTagView.imageCollectionView.setContentOffset(.zero, animated: false)

        mainView.photoTagView.imageCollectionView.reloadData()
        updateCollectionViewHeight(!images.isEmpty) // 이미지가 있으면 컬렉션 뷰 높이 설정, 없으면 숨김
        mainView.photoTagView.layoutIfNeeded()
    }
}

// 전송할 리스트 이벤트
extension RecordOOTDViewController: ContentInputViewDelegate {
    
    func contentInputView(_ view: ContentInputView, didUpdateText text: String) {
        self.contentText = text
    }
    
    func contentInputView(_ view: ContentInputView, didTogglePublic isPublic: Bool) {
        self.isPublic = isPublic
    }
    
    // 해시태그 추가
    func contentInputView(_ view: ContentInputView, didAddHashtag hashtag: String) {
        hashtags.append(hashtag)
        print("Current hashtags:", hashtags)
    }
    
    // 해시태그 삭제
    func contentInputView(_ view: ContentInputView, didRemoveHashtag hashtag: String) {
        if let index = hashtags.firstIndex(of: hashtag) {
            hashtags.remove(at: index)
            print("Current hashtags:", hashtags)
        }
    }
    
    // 키보드 애니메이션 처리
    func contentInputView(_ view: ContentInputView, shouldMoveWithKeyboard offset: CGFloat) {
            UIView.animate(withDuration: 0.3) {
            self.mainView.scrollView.contentOffset = CGPoint(x: 0, y: -offset)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension RecordOOTDViewController: UICollectionViewDelegate {
    // 필요한 delegate 메서드 구현
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 태그 컬렉션뷰 선택 시 처리
        if collectionView == mainView.photoTagView.tagCollectionView {
            // 필요한 경우 여기에 태그 선택 처리 로직 추가
        }
    }
}

// MARK: - TagClothViewControllerDelegate
// TagClothViewController에서 선택한 옷 데이터 받기
extension RecordOOTDViewController: TagClothViewControllerDelegate {

    func didSelectTags(_ tags: [(id: Int, image: UIImage, title: String)]) {
        self.taggedItems = tags
        
        // 컬렉션 뷰를 새로고침 해서 UI 업데이트
        mainView.photoTagView.tagCollectionView.reloadData()
        
        // 컬렉션 뷰 Height 값 처리
        mainView.photoTagView.updateTagCollectionViewHeight(!tags.isEmpty)
        
        // 기록하기 확인 버튼 활성화/비활성화
        if !tags.isEmpty {
            mainView.OOTDButton.setEnabled(true)
        } else {
            mainView.OOTDButton.setEnabled(false)
        }
    }
}

// 수정하기 - 데이터 불러오기
extension RecordOOTDViewController {
    /*
     Mutation of captured var in concurrently-executing code 오류
     - swift5까지는 클로저 내부에서 외부 변수를 참조한 변수들을 여러 스레드에서 동시에 수정하는 것이 가능했음.
     - 그러나 이 방식은 데이터 경쟁(Race Condition)을 발생할 가능성이 높아 swift6 부터는 금지함.
     - DispatchQueue를 생성하여 loadedImages.append() 작업을 동기적으로 실행되게 수정하여 경쟁 상태 예방.
    */
    // 태그한 옷 불러오기
    func loadTaggedClothes(from cloths: [CalendarDetailViewModel.ClothDTO]) {
        // 비동기 네트워크 요청 관리를 위한 DispatchGroup 생성
        let dispatchGroup = DispatchGroup()
        var loadedClothes: [(id: Int, image: UIImage, title: String)] = []
        let syncQueue = DispatchQueue(label: "clothSyncQueue")

        for cloth in cloths {
            if let url = URL(string: cloth.imageUrl) {
                dispatchGroup.enter()
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    switch result {
                    case .success(let imageResult):
                        syncQueue.sync { // 동기적으로 실행
                            loadedClothes.append((id: cloth.clothId, image: imageResult.image, title: cloth.name))
                        }
                    case .failure(let error):
                        print("옷 이미지 로드 실패: \(error)")
                    }
                    dispatchGroup.leave()
                }
            }
        }
        // 모든 비동기 요청이 완료된 후 메인 스레드에서 실행
        dispatchGroup.notify(queue: .main) {
            self.taggedItems = loadedClothes
            self.mainView.photoTagView.tagCollectionView.reloadData()
            self.mainView.photoTagView.updateTagCollectionViewHeight(!loadedClothes.isEmpty)
        }
    }

    // 이미지 로드 - kingfisher 사용
    func loadImages(from urls: [String]) {
        let dispatchGroup = DispatchGroup()
        var loadedImages: [UIImage] = []
        let syncQueue = DispatchQueue(label: "imageSyncQueue")

        for urlString in urls {
            if let url = URL(string: urlString) {
                dispatchGroup.enter()
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    switch result {
                    case .success(let imageResult):
                        syncQueue.sync { // 동기적으로 실행
                            loadedImages.append(imageResult.image)
                        }
                    case .failure(let error):
                        print("이미지 로드 실패: \(error)")
                    }
                    dispatchGroup.leave()
                }
            }
        }
        // 모든 비동기 요청이 완료된 후 메인 스레드에서 실행
        dispatchGroup.notify(queue: .main) {
            self.selectedImages = loadedImages
            self.mainView.photoTagView.imageCollectionView.reloadData()
            self.mainView.updateCollectionViewHeight(!loadedImages.isEmpty)
        }
        mainView.OOTDButton.setEnabled(true)
    }
}
