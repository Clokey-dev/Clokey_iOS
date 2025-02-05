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

class CustomGalleryViewController: UIViewController {
    
    // MARK: - Properties
    
    // weak var로 선언하여 순환 참조 방지
    weak var delegate: CustomGalleryViewControllerDelegate?
    
    // 로딩 인디케이터
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // PHFetchResult는 사진 라이브러리의 데이터를 배열처럼 관리하는 객체 + 실시간 업데이트 지원
    private var images: PHFetchResult<PHAsset>?
    private let imageManager = PHImageManager.default() // PHAsset으로 부터 이미지 요청 및 처리
    private var selectedAssets: [PHAsset] = []
    
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
        let group = DispatchGroup() // 비동기 작업 처리 그룹
        var selectedImages: [UIImage] = [] // 불러오기 성공한 이미지 배열

        // 로딩 인디케이터 표시
        showLoadingIndicator()
        view.isUserInteractionEnabled = false

        // 선택된 PHAsset을 이미지(UIImage)로 변환하는 비동기 요청
        for asset in selectedAssets {
            group.enter() // 비동기 작업 시작
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat // 고품질 이미지 요청
            options.isSynchronous = false // 비동기적으로 이미지 로드
            options.isNetworkAccessAllowed = true // 클라우드(iCloud)에 저장된 이미지 다운로드 허용

            imageManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize, // 원본 크기의 이미지 요청
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                if let image = image {
                    selectedImages.append(image) // 이미지가 정상적으로 로드되면 배열에 추가
                } else {
                    print("이미지 로드 실패: \(asset)") // 디버깅을 위해 실패한 경우 로그 출력
                }
                group.leave() // 해당 이미지 로드 작업 완료
            }
        }

        // 모든 비동기 작업이 끝나면 실행되는 코드
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.hideLoadingIndicator() // 로딩 인디케이터 숨기기
            self.view.isUserInteractionEnabled = true // 터치 다시 활성화

            if selectedImages.isEmpty {
                self.showErrorAlert() // 모든 이미지 로드 실패 시 경고창 표시
                return
            }
            
            // 로드된 이미지들을 PhotoEditViewController로 전달
            self.delegate?.galleryViewController(self, didSelect: selectedImages)
            self.dismiss(animated: true) // 현재 뷰 닫기
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
        
        // GalleryCell 재사용
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        
        if let asset = images?.object(at: indexPath.item) {
            imageManager.requestImage(for: asset,
                                   targetSize: CGSize(width: 200, height: 200),
                                   contentMode: .aspectFill,
                                   options: nil) { image, _ in
                cell.imageView.image = image
            }
        }
        
        return cell
    }
    
    // 사용자가 특정 셀을 선택했을 때 실행되는 동작을 정의
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = images?.object(at: indexPath.item) else { return }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? GalleryCell {
            if let index = selectedAssets.firstIndex(of: asset) {
                selectedAssets.remove(at: index)
                cell.setSelected(false)
            } else {
                selectedAssets.append(asset)
                cell.setSelected(true)
            }
            
            completeButton.isHidden = selectedAssets.isEmpty
        }
    }
}

// MARK: - Gallery Cell
class GalleryCell: UICollectionViewCell {
    
    // 이미지 뷰
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    // 사용자가 이미지를 선택했을 경우
    private let selectedOverlay = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.isHidden = true
    }
    
    // 이미지 체크 마크
    private let checkmarkImageView = UIImageView().then {
        $0.image = UIImage(systemName: "checkmark.circle.fill")
        $0.tintColor = .white
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
        contentView.addSubview(selectedOverlay)
        contentView.addSubview(checkmarkImageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        selectedOverlay.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkmarkImageView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(24)
        }
        
    }

    // 선택된 이미지
    func setSelected(_ isSelected: Bool) {
        selectedOverlay.isHidden = !isSelected
        checkmarkImageView.isHidden = !isSelected
    }
    
    // 셀 재사용 전 초기화 담당
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}


