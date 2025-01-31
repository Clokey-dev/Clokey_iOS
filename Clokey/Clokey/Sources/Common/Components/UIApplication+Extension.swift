//
//  UIApplication+Extension.swift
//  Clokey
//
//  Created by 소민준 on 1/31/25.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
