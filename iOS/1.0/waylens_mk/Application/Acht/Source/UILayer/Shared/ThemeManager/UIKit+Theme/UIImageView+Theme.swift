//
//  UIImageView+Theme.swift
//  Acht
//
//  Created by forkon on 2020/3/26.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIImageView {

    private struct AssociatedKeys {
        static var usingDynamicTintColor: UInt8 = 0
        static var disposeBag: UInt8 = 1
        static var semanticTintColor: UInt8 = 2
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

    private var semanticTintColor: TintColor? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.semanticTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.semanticTintColor) as? TintColor
        }
    }

    // ⚠️ Do not modify this property name directly, you must find and replace all, because it's used by many .storyboard and .xib files!
    @IBInspectable final var usingDynamicTintColor: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.usingDynamicTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            if newValue {
                replaceTextColorWithDynamicColor()

                rx.methodInvoked(#selector(UIView.traitCollectionDidChange(_:))).subscribe { [weak self] (event) in
                    guard let self = self else {
                        return
                    }

                    if let semanticTintColor = self.semanticTintColor {
                        self.tintColor = UIColor.semanticColor(.tint(semanticTintColor))
                    }
                }.disposed(by: disposeBag)
            }
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.usingDynamicTintColor) as? Bool) ?? false
        }
    }

    private func replaceTextColorWithDynamicColor() {
        TintColor.allCases.forEach { (tintColor) in
            if self.tintColor.isSameColorAs(UIColor.semanticColor(.tint(tintColor), usingTheme: LightTheme())) {
                semanticTintColor = tintColor
                self.tintColor = UIColor.semanticColor(.tint(tintColor))
                return
            }
        }
    }

}
