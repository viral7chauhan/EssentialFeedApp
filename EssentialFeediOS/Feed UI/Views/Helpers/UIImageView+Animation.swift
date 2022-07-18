//
//  UIImageView+Animation.swift
//  EssentialFeediOS
//
//  Created by Viral on 26/05/22.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage

        guard let _ = newImage else { return }

        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
