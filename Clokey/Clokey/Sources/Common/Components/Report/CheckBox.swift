//
//  CheckBox.swift
//  Report
//
//  Created by 한금준 on 3/5/25.
//

import Foundation
import UIKit

class CheckBox: UIButton {

    /// 체크박스 이미지
    var checkBoxResouces = OnOffResources(
        onImage: UIImage(systemName: "checkmark.circle.fill"),
        offImage: UIImage(systemName: "circle")
    ) {
        didSet {
            self.setChecked(isChecked)
        }
    }

    /// 체크 상태 변경
    var isChecked: Bool = false {
        didSet {
            guard isChecked != oldValue else { return }
            self.setChecked(isChecked)
        }
    }

    /// 이미지 직접 지정 + init
    init(resources: OnOffResources) {
        super.init(frame: .zero)
        self.checkBoxResouces = resources
        commonInit()
    }

    /// 일반적인 init + checkBoxResources 변경
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        self.setImage(checkBoxResouces.offImage, for: .normal)

        self.tintColor = UIColor.mainBrown800
        
        self.addTarget(self, action: #selector(check), for: .touchUpInside)
        self.isChecked = false
    }

    @objc func check(_ sender: UIGestureRecognizer) {
        isChecked.toggle()
    }

    /// 이미지 변경
    private func setChecked(_ isChecked: Bool) {
        if isChecked == true {
            self.setImage(checkBoxResouces.onImage, for: .normal)
        } else {
            self.setImage(checkBoxResouces.offImage, for: .normal)
        }
    }

    class OnOffResources {

        let onImage: UIImage?
        let offImage: UIImage?

        init(onImage: UIImage?, offImage: UIImage?) {
            self.onImage = onImage
            self.offImage = offImage
        }
    }
}
