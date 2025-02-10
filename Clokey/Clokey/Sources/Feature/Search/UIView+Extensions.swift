

//
//  UIView+Extensions.swift
//  Clokey
//
//  Created by 소민준 on 2/9/25.
//

import UIKit

extension UIView {
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
