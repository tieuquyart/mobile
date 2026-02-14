//
//  UIView+Theme.swift
//  Acht
//
//  Created by forkon on 2020/3/23.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIView {

    private struct AssociatedKeys {
        static var usingDynamicBackgroundColor: UInt8 = 0
        static var disposeBag: UInt8 = 1
        static var semanticBackgroundColor: UInt8 = 2
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

    private var semanticBackgroundColor: BackgroundColor? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.semanticBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.semanticBackgroundColor) as? BackgroundColor
        }
    }

    // ⚠️ Do not modify this property name directly, you must find and replace all, because it's used by many .storyboard and .xib files!
    @IBInspectable final var usingDynamicBackgroundColor: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.usingDynamicBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            if newValue {
                replaceBackgroundColorWithDynamicColor()

                rx.methodInvoked(#selector(UIView.traitCollectionDidChange(_:))).subscribe { [weak self] (event) in
                    guard let self = self else {
                        return
                    }

                    if let semanticBackgroundColor = self.semanticBackgroundColor {
                        self.backgroundColor = UIColor.semanticColor(.background(semanticBackgroundColor))
                    }
                }.disposed(by: disposeBag)
            }
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.usingDynamicBackgroundColor) as? Bool) ?? false
        }
    }

    private func replaceBackgroundColorWithDynamicColor() {
        BackgroundColor.allCases.forEach { (backgroundColor) in
            if self.backgroundColor?.isSameColorAs(UIColor.semanticColor(.background(backgroundColor), usingTheme: LightTheme())) == true {
                semanticBackgroundColor = backgroundColor
                self.backgroundColor = UIColor.semanticColor(.background(backgroundColor))
                return
            }
        }
    }

}
