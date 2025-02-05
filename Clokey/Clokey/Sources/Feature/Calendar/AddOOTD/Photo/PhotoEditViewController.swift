//
//  PhotoEditViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/21/25.
//

import UIKit
import Photos
import TOCropViewController

// 사진 편집 작업 프로토콜
protocol PhotoEditViewControllerDelegate: AnyObject {
    func photoEditViewController(_ viewController: PhotoEditViewController, didFinishEditing images: [UIImage])
}

class PhotoEditViewController: UIViewController {
    
    // MARK: - Properties
    
    // 편집중인 이미지 배열
    private var selectedImages: [UIImage] = []
    // 현재 편집중인 이미지
    private var currentEditingIndex: Int = 0
    weak var delegate: PhotoEditViewControllerDelegate?
    
    let navBarManager = NavigationBarManager() // 네비게이션 바
    
    // MARK: - UI Components
    
    // 썸네일 컬렉션 뷰
    private let thumbnailCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout() // 레이아웃 설정
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 80)
        layout.minimumInteritemSpacing = 8
        
        // 컬렉션 뷰
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        return cv
    }()
    
    // 메인 이미지 - 선택된 이미지
    private let mainImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    // 자르기 버튼
    private let cropButton = UIButton().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 15
        
        // 버튼 그림자
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 8
        
        $0.setImage(UIImage(systemName: "crop"), for: .normal)
        $0.tintColor = .black
        
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    // 편집 완료 버튼
    private let completeButton = CustomButton(title: "편집완료", isEnabled: true)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupActions()
        updateMainImage()
        
        // 키보드..?
        hideKeyboardWhenTappedAround()
        
        // 터치 이벤트가 스크롤 동작으로 인해 취소되지 않도록 설정
        thumbnailCollectionView.canCancelContentTouches = false
        
    }
    
    // 키보드 관련.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // 네비게이션 뒤로가기
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(didTapBackButton)
        )

        // 네비게이션 타이틀
        navBarManager.setTitle(
            to: navigationItem,
            title: "사진 편집",
            font: .systemFont(ofSize: 18, weight: .semibold), textColor: .black
        )

        view.addSubview(thumbnailCollectionView)
        view.addSubview(mainImageView)
        view.addSubview(cropButton)
        view.addSubview(completeButton)
        
        // 썸네일 컬렉션 뷰
        thumbnailCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(80)
        }
        
        // 선택 메인 이미지
        mainImageView.snp.makeConstraints {
            $0.top.equalTo(thumbnailCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(completeButton.snp.top).offset(-16)
        }
        
        // 자르기 버튼
        cropButton.snp.makeConstraints {
            $0.top.equalTo(mainImageView).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(30)
        }
        
        // 편집 완료
        completeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(54)
        }
    }
    
    // 썸네일 컬렉션 뷰 데이터소스&델리게이트 설정
    private func setupCollectionView() {
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
    }
    
    // 각 버튼 액션 설정
    private func setupActions() {
        cropButton.addTarget(self, action: #selector(didTapCropButton), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
    }
    
    // MARK: - Public Methods
    // 외부에서 데이터를 전달받기 위한 메서드
    // PhotoEditViewController는 편집 화면을 표시하기 전, 편집할 이미지 데이터를 외부에서 전달받도록 설계
    // 편집 뷰를 열 때, 선택된 이미지를 전달받아 설정
    func configure(with images: [UIImage]) {
        self.selectedImages = images
        thumbnailCollectionView.reloadData()
        updateMainImage()
    }
    
    // MARK: - Private Methods
    // 메인 이미지 업데이트
    private func updateMainImage() {
        guard currentEditingIndex < selectedImages.count else { return }
        mainImageView.image = selectedImages[currentEditingIndex]
    }
    
    // 사진 크롭 뷰
    private func showCropViewController() {
        guard currentEditingIndex < selectedImages.count else { return }
        let image = selectedImages[currentEditingIndex]
        // TOcrop 외부 라이브러리 사용
        let cropViewController = TOCropViewController(croppingStyle: .default, image: image)
        cropViewController.delegate = self
        
        // 3:4 비율 설정
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.customAspectRatio = CGSize(width: 3, height: 4)
        
        present(cropViewController, animated: true)
    }
    
    // MARK: - Actions
    // 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.dismiss(animated: true)
    }
    
    // 크롭 버튼 이벤트
    @objc private func didTapCropButton() {
        showCropViewController()
    }
    
    // 편집 완료
    @objc private func didTapCompleteButton() {
        // 최종 이미지 배열
        var finalImages: [UIImage] = []
        let group = DispatchGroup()
        
        for image in selectedImages {
            group.enter()
            
            // 자동 크롭 함수 : 사용자가 따로 편집을 하지 않았을 경우 자동으로 3:4 비율로 크롭
            let croppedImage = autoCropToRatio(image, ratio: 3.0/4.0)
            finalImages.append(croppedImage)
            group.leave()
        }
        
        // 그룹 작업 완료
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.delegate?.photoEditViewController(self, didFinishEditing: finalImages)
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    // 자동으로 3:4 비율 크롭 메서듬
    private func autoCropToRatio(_ image: UIImage, ratio: CGFloat) -> UIImage {
        let width = image.size.width
        let height = image.size.height
        let currentRatio = width / height
        
        var cropRect: CGRect
        
        if currentRatio > ratio {
            // 이미지가 더 넓은 경우
            let newWidth = height * ratio
            let x = (width - newWidth) / 2  // 중앙 기준
            cropRect = CGRect(x: x, y: 0, width: newWidth, height: height)
        } else {
            // 이미지가 더 긴 경우
            let newHeight = width / ratio
            let y = (height - newHeight) / 2  // 중앙 기준
            cropRect = CGRect(x: 0, y: y, width: width, height: newHeight)
        }
        
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage)
        }
        
        return image  // 크롭 실패시 원본 반환
    }

}

// MARK: - UICollectionView DataSource & Delegate
// 이미지 컬렉션 뷰에 데이터 제공
extension PhotoEditViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // 컬렉션 뷰 셀의 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    // 컬렉션 뷰의 특정 위치에 표시할 셀 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionViewCell.identifier,
            for: indexPath
        ) as! ImageCollectionViewCell
        cell.configure(with: selectedImages[indexPath.item])
        cell.hideDeleteButton()
        return cell
    }
    
    // 사용자가 컬렉션 뷰의 특정 셀을 선택 -> 메인 이미지 업데이트
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentEditingIndex = indexPath.item
        updateMainImage()
    }
}

// MARK: - TOCropViewControllerDelegate
// 이미지 크롭 작업이 완료되었을 때 호출
extension PhotoEditViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        selectedImages[currentEditingIndex] = image
        thumbnailCollectionView.reloadItems(at: [IndexPath(item: currentEditingIndex, section: 0)])
        updateMainImage()
        cropViewController.dismiss(animated: true)
    }
}

// 키보드 내리기
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
