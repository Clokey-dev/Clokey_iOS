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
        
        NotificationCenter.default.addObserver(self, selector: #selector(resumeAnimation), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func setupAnimation() {
        view.backgroundColor = .white

        animationView.do {
            $0.animation = LottieAnimation.named(animationName)
            $0.contentMode = .scaleAspectFit
            $0.loopMode = .playOnce
            $0.animationSpeed = 1.7
        }

        view.addSubview(animationView)

        animationView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        animationView.play { [weak self] finished in
            if finished {
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
    // 애니메이션 재실행
    @objc private func resumeAnimation() {
        animationView.stop()
        animationView.play { [weak self] finished in
            if finished {
                self?.animationCompletionHandler?()
            }
        }
    }

}
