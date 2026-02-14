//
//  UITextField+Theme.swift
//  Acht
//
//  Created by forkon on 2020/3/23.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UITextField {

    private struct AssociatedKeys {
        static var usingDynamicTextColor: UInt8 = 0
        static var disposeBag: UInt8 = 1
        static var semanticLabelColor: UInt8 = 2
    }

    private var disposeBag: DisposeBag {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var disposeBag = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag
            if disposeBag == nil {
                disposeBag = DisposeBag()
                objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }

            return disposeBag!
        }
    }

    private var semanticLabelColor: LabelColor? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.semanticLabelColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.semanticLabelColor) as? LabelColor
        }
    }

    // ⚠️ Do not modify this property name directly, you must find and replace all, because it's used by many .storyboard and .xib files!
    @IBInspectable final var usingDynamicTextColor: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.usingDynamicTextColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            if newValue {
                replaceTextColorWithDynamicColor()

                rx.methodInvoked(#selector(UIView.traitCollectionDidChange(_:))).subscribe { [weak self] (event) in
                    guard let self = self else {
                        return
                    }

                    if let semanticLabelColor = self.semanticLabelColor {
                        self.textColor = UIColor.semanticColor(.label(semanticLabelColor))
                    }
                }.disposed(by: disposeBag)
            }
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.usingDynamicTextColor) as? Bool) ?? false
        }
    }

    private func replaceTextColorWithDynamicColor() {
        LabelColor.allCases.forEach { (labelColor) in
            if let textColor = textColor, textColor.isSameColorAs(UIColor.semanticColor(.label(labelColor), usingTheme: LightTheme())) {
                semanticLabelColor = labelColor
                self.textColor = UIColor.semanticColor(.label(labelColor))
                return
            }
        }
    }

}
