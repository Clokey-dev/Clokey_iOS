//
//  CustomGalleryViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/21/25.
//

import Foundation
import UIKit
import Photos

// 특정 작업(이미지 선택)을 완료 했을 때 외부에 알리고 처리할 수 있게 설계
protocol CustomGalleryViewControllerDelegate: AnyObject { // AnyObject 타입으로 모든 클래스 타입 채택 -> 약한(weak) 참조 가능
    // galleryViewController에서 사용
    func galleryViewController(_ viewController: CustomGalleryViewController, didSelect images: [UIImage])
}

class CustomGalleryViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    // weak var로 선언하여 순환 참조 방지
    weak var delegate: CustomGalleryViewControllerDelegate?
    
    // 로딩 인디케이터
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // PHFetchResult는 사진 라이브러리의 데이터를 배열처럼 관리하는 객체 + 실시간 업데이트 지원
    private var images: PHFetchResult<PHAsset>?
    private let imageManager = PHImageManager.default() // PHAsset으로 부터 이미지 요청 및 처리
    private var selectedAssets: [(asset: PHAsset, index: Int)] = []

    let navBarManager = NavigationBarManager()
    
    // MARK: - UI Components
    
    // 이미지 컬렉션 뷰
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout() // 레이아웃 설정
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        let width = (UIScreen.main.bounds.width - 3) / 4 // 화면 크기 기준 4개의 셀 균등 배치
        layout.itemSize = CGSize(width: width, height: width) //
        
        // 이미지 컬렉션 뷰
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: "GalleryCell")
        collectionView.delegate = self // 사용자 인터렉션 처리
        collectionView.dataSource = self // 컬렉션 뷰에 데이터 제공
        return collectionView
    }()
    
    // 최근항목 라벨
    private let recentPicLabel = UILabel().then {
        $0.text = "최근항목"
        $0.font = .ptdRegularFont(ofSize: 16)
        $0.textColor = .gray
    }
    
    // 완료 버튼
    private let completeButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.titleLabel?.font = .ptdSemiBoldFont(ofSize: 16)
        $0.setTitleColor(.pointOrange800, for: .normal)
        $0.isHidden = true
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        checkPhotoLibraryPermission()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    // MARK: - Setup
    private func setupUI() {
       view.backgroundColor = .white
       
        // 네비게이션 뒤로가기
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(backButtonTapped)
        )

        // 네비게이션 타이틀
        navBarManager.setTitle(
            to: navigationItem,
            title: "캘린더에 기록하기",
            font: .ptdBoldFont(ofSize: 20),
            textColor: .black
        )
       
        let headerView = UIView()
        view.addSubview(headerView)
        headerView.addSubview(recentPicLabel)
        headerView.addSubview(completeButton)
        view.addSubview(collectionView)
       
        // 헤더뷰 제약조건
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(22)
        }
        
        // 최근 항목 라벨
        recentPicLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        // 완료 버튼
        completeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
       
        // 이미지 컬렉션 뷰
        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // 갤러리 접근 권한 요청
    private func checkPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            if status == .authorized {
                DispatchQueue.main.async {
                    self?.fetchPhotos()
                }
            }
        }
    }
    
    // 갤러리의 이미지를 가져와서 컬렉션 뷰에 표시
    private func fetchPhotos() {
        let options = PHFetchOptions() // 사진 라이브러리에서 데이터를 가져올 때 사용할 옵션
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] // 생성일자를 기준으로 사진을 가져옴
        // PHAsset은 사진 또는 동영상을 나타내는 객체
        images = PHAsset.fetchAssets(with: .image, options: options)
        collectionView.reloadData() // 컬렉션 뷰의 데이터를 다시 로드하여 UI 업데이트
    }
    
    // MARK: - Actions
    
    // 각 버튼 액션 설정
    private func setupActions() {
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func completeButtonTapped() {
        didTapCompleteButton()
    }
    
    // 이미지 추가 버튼 + 대기 인디케이터
    @objc private func didTapCompleteButton() {
        let group = DispatchGroup()
        var selectedImages: [(index: Int, image: UIImage)] = []

        showLoadingIndicator()
        view.isUserInteractionEnabled = false

        for (asset, index) in selectedAssets {
            group.enter()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true

            imageManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                if let image = image {
                    selectedImages.append((index, image))
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            self.view.isUserInteractionEnabled = true

            if selectedImages.isEmpty {
                self.showErrorAlert()
                return
            }

            // index 기준으로 정렬 후 PhotoEditViewController로 전달
            let sortedImages = selectedImages.sorted { $0.index < $1.index }.map { $0.image }
            
            let photoEditVC = PhotoEditViewController()
            photoEditVC.configure(with: sortedImages)
            self.navigationController?.pushViewController(photoEditVC, animated: true)
        }
    }


    // 이미지 로드 실패 시 사용자에게 알림 표시
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "이미지 로드 실패",
            message: "일부 이미지를 불러오는 데 실패했습니다. 다시 시도해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func showLoadingIndicator() {
        loadingIndicator.color = .pointOrange800 // 로딩 인디케이터 색상 설정
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false // Auto Layout 활성화
        view.addSubview(loadingIndicator) // 뷰에 추가
        
        // 로딩 인디케이터를 화면 중앙에 배치
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        loadingIndicator.startAnimating() // 로딩 애니메이션
    }

    // 로딩 인디케이터 제거 메서드
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
    }
}


// MARK: - UICollectionView DataSource & Delegate
// 컬렉션 뷰 데이터소스&델리게이트
extension CustomGalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // 컬렉션 뷰에 특정 섹션에 몇 개의 셀을 표시할 지 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    // 특정 위치(indexPath)에 표시할 셀을 생성하고 데이터를 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell

        if indexPath.item == 0 {
            // 첫 번째 셀 - 카메라 버튼
            cell.configure(with: nil, isCameraCell: true)
        } else if let asset = images?.object(at: indexPath.item - 1) {
            imageManager.requestImage(for: asset,
                                      targetSize: CGSize(width: 200, height: 200),
                                      contentMode: .aspectFill,
                                      options: nil) { image, _ in
                DispatchQueue.main.async {
                    if let currentCell = collectionView.cellForItem(at: indexPath) as? GalleryCell {
                        currentCell.configure(with: image)
                    }
                }
            }

            // 선택 순서 유지
            if let selectedIndex = selectedAssets.firstIndex(where: { $0.asset == asset }) {
                let order = selectedAssets[selectedIndex].index
                cell.setSelectionOrder(order)
            } else {
                cell.setSelectionOrder(nil)
            }
        }

        return cell
    }

    // 특정 셀 선택 시, 기능 관리
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            openCamera() // 카메라 열기
            return
        }

        guard let asset = images?.object(at: indexPath.item - 1) else { return }

        var reloadIndexPaths: [IndexPath] = [indexPath]

        if let index = selectedAssets.firstIndex(where: { $0.asset == asset }) {
            selectedAssets.remove(at: index)
        } else {
            let newIndex = selectedAssets.count + 1
            selectedAssets.append((asset, newIndex))
        }

        for (i, asset) in selectedAssets.enumerated() {
            selectedAssets[i] = (asset.asset, i + 1)
            if let updatedIndex = images?.index(of: asset.asset) {
                reloadIndexPaths.append(IndexPath(item: updatedIndex + 1, section: 0))
            }
        }

        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: reloadIndexPaths)
        }

        updateCompleteButtonState()
    }

    private func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }

    // 완료 버튼 상태 업데이트
    private func updateCompleteButtonState() {
        completeButton.isHidden = selectedAssets.isEmpty
    }


}

// MARK: - Gallery Cell
class GalleryCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    // 선택 순서 표시
    private let orderLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 14)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        $0.textAlignment = .center
        $0.isHidden = true  // 기본적으로 숨김
    }

    // 카메라 아이콘
    private let cameraIconView = UIImageView().then {
        $0.image = UIImage(systemName: "camera.fill")
        $0.tintColor = .white
        $0.contentMode = .center
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(orderLabel)
        contentView.addSubview(cameraIconView)

        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        orderLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(8)
            $0.width.height.equalTo(24)
        }
        cameraIconView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // 카메라 셀 구분
    func configure(with image: UIImage?, isCameraCell: Bool = false) {
        if isCameraCell {
            cameraIconView.isHidden = false
            imageView.isHidden = true
        } else {
            cameraIconView.isHidden = true
            imageView.isHidden = false
            imageView.image = image
        }
    }

    // 선택 순서 라벨 유지
    func setSelectionOrder(_ order: Int?) {
        if let order = order {
            orderLabel.text = "\(order)"
            orderLabel.isHidden = false
        } else {
            orderLabel.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        orderLabel.isHidden = true
        cameraIconView.isHidden = true
    }
}
// 카메라 기능
extension CustomGalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                self.savePhotoToLibrary(image)
            }
        }
    }

    private func savePhotoToLibrary(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.fetchPhotos() // 사진 추가 후 갤러리 새로고침
                }
            } else {
                print("사진 저장 실패: \(error?.localizedDescription ?? "")")
            }
        }
    }
}
