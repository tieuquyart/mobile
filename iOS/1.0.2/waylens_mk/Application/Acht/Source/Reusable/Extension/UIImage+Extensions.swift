//
//  UIImage+Extensions.swift
//  Acht
//
//  Created by forkon on 2020/7/1.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

extension UIImage {

    public func image(with insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)

        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return imageWithInsets
    }

    public func image(with newSize: CGSize) -> UIImage? {
        return image(with: UIEdgeInsets(
            top: (newSize.height - size.height) / 2,
            left: (newSize.width - size.width) / 2,
            bottom: (newSize.height - size.height) / 2,
            right: (newSize.width - size.width) / 2)
        )
    }

}
