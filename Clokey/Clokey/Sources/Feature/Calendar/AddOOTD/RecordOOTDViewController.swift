//
//  RecordOOTDViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/20/25.
//

import UIKit

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
                // 이미지 크기 조정 (최대 1024x1024)
                let maxSize: CGFloat = 1024
                var newImage = image
                
                if image.size.width > maxSize || image.size.height > maxSize {
                    let ratio = min(maxSize/image.size.width, maxSize/image.size.height)
                    let newSize = CGSize(
                        width: image.size.width * ratio,
                        height: image.size.height * ratio
                    )
                    
                    UIGraphicsBeginImageContext(newSize)
                    image.draw(in: CGRect(origin: .zero, size: newSize))
                    newImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
                    UIGraphicsEndImageContext()
                }
                
                return newImage.jpegData(compressionQuality: 0.5)
            }
            
            let historyService = HistoryService()
            historyService.historyCreate(data: requestDTO, images: imageDataArray) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    print("History created successfully with ID: \(response.historyId)")
                    DispatchQueue.main.async {
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
                collectionView.reloadData()
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
        mainView.photoTagView.imageCollectionView.reloadData()
        updateCollectionViewHeight(!images.isEmpty) // 이미지가 있으면 컬렉션 뷰 높이 설정, 없으면 숨김
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
