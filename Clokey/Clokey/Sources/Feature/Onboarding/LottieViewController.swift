//
//  LottieViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/15/25.
//

import UIKit
import Lottie

class LottieViewController: UIViewController {
    
    private let animationView = LottieAnimationView()
    private let animationName: String
    var animationCompletionHandler: (() -> Void)?
    private var tapCompletionHandler: (() -> Void)?

    init(animationName: String) {
        self.animationName = animationName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimation()
    }

    private func setupAnimation() {
        // 애니메이션 뷰 설정
        animationView.animation = LottieAnimation.named(animationName)
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.7
        view.addSubview(animationView)
        
        // 배경색 설정 (선택사항)
        view.backgroundColor = .white

        // 애니메이션 실행
        animationView.play { [weak self] finished in
            if finished {
                print("Animation finished")
                self?.animationCompletionHandler?()
            }
        }
    }

    // 터치 감지
    func enableTapToProceed(completion: @escaping () -> Void) {
        print("Tap gesture being enabled")
        tapCompletionHandler = completion
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.isUserInteractionEnabled = true
        animationView.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        tapCompletionHandler?() // 터치 후 실행
    }
}
