//
//  UIView+Extensions.swift
//  lego-ar-world-app
//
//  Created by Srinjoy Majumdar on 1/1/19.
//  Copyright © 2019 Srinjoy Majumdar. All rights reserved.
//

import UIKit

extension UITextView {
    func fadeTo(_ alpha: CGFloat, duration: TimeInterval? = 0.3) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration != nil ? duration! : 0.3) {
                self.alpha = alpha
            }
        }
    }
    
    func fadeIn(_ duration: TimeInterval? = 0.3) {
        fadeTo(1.0, duration: duration)
    }
    func fadeOut(_ duration: TimeInterval? = 0.3) {
        fadeTo(0.0, duration: duration)
    }
}
