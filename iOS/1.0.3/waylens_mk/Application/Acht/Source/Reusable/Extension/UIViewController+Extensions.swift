//
//  UIViewController+Extensions.swift
//  Acht
//
//  Created by forkon on 2018/9/20.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation

extension UIPopoverPresentationController {

    fileprivate struct AssociatedKeys {
        static var didDismissClosureKey: UInt8 = 0
    }

    fileprivate var didDismissClosure: (() -> ())? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.didDismissClosureKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.didDismissClosureKey) as? (() -> ())
        }
    }

}

extension UIViewController: UIPopoverPresentationControllerDelegate {

    func popout(_ viewControllerToPopout: UIViewController, preferredContentSize: CGSize, tapBackgroundToDismiss: Bool = false, from sourceView: UIView, didPresent: (() -> ())? = nil, didDismiss: (() -> ())? = nil) {
        
        viewControllerToPopout.modalPresentationStyle = .popover
        viewControllerToPopout.preferredContentSize = preferredContentSize
        viewControllerToPopout.popoverPresentationController?.sourceView = sourceView
        viewControllerToPopout.popoverPresentationController?.sourceRect = sourceView.bounds
        viewControllerToPopout.popoverPresentationController?.permittedArrowDirections = .up
        viewControllerToPopout.popoverPresentationController?.delegate = self
        viewControllerToPopout.popoverPresentationController?.didDismissClosure = didDismiss
        viewControllerToPopout.popoverPresentationController?.passthroughViews = tapBackgroundToDismiss ? nil : [self.view]

        present(viewControllerToPopout, animated: true, completion: didPresent)
    }

    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.didDismissClosure?()
        popoverPresentationController.didDismissClosure = nil
    }

    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }

}

extension UIViewController {

    var previousViewControllerInNavigationStack: UIViewController? {
        guard let viewControllers = navigationController?.viewControllers, let index = viewControllers.lastIndex(of: self), index >= 1 else {
            return nil
        }
        return viewControllers[index - 1]
    }

}

extension UIViewController {

    private static var doneSwizzling: Bool = false

    private struct AssociatedKeys {
        static var needsHideNavigationBar: UInt8 = 88
    }

    var needsHideNavigationBar: Bool {
        set(needs) {
            objc_setAssociatedObject(self, &AssociatedKeys.needsHideNavigationBar, needs, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)

            if needs && !UIViewController.doneSwizzling {
                guard
                    let viewWillAppearMethod: Method = class_getInstanceMethod(object_getClass(self), #selector(viewWillAppear(_:))),
                    let swizzledViewWillAppearMethod: Method = class_getInstanceMethod(object_getClass(self), #selector(swizzling_viewWillAppear(_:))),
                    let viewWillDisappearMethod: Method = class_getInstanceMethod(object_getClass(self), #selector(viewWillDisappear(_:))),
                    let swizzledViewWillDisappearMethod: Method = class_getInstanceMethod(object_getClass(self), #selector(swizzling_viewWillDisappear(_:)))
                    else {
                        return
                }

                method_exchangeImplementations(viewWillAppearMethod, swizzledViewWillAppearMethod)
                method_exchangeImplementations(viewWillDisappearMethod, swizzledViewWillDisappearMethod)

                UIViewController.doneSwizzling = true
            }
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.needsHideNavigationBar) as? Bool) ?? false
        }
    }

    @objc private dynamic func swizzling_viewWillAppear(_ animated: Bool) {
        swizzling_viewWillAppear(animated)

        if presentedViewController == nil { // will not occur when present or dismiss a view controller
            if needsHideNavigationBar {
                navigationController?.setNavigationBarHidden(true, animated: animated)
            } else {
                navigationController?.setNavigationBarHidden(false, animated: animated)
            }
        }
    }

    @objc private dynamic func swizzling_viewWillDisappear(_ animated: Bool) {
        swizzling_viewWillDisappear(animated)

        if presentedViewController == nil { // will not occur when present or dismiss a view controller
            if needsHideNavigationBar {
                navigationController?.setNavigationBarHidden(false, animated: animated)
            } else {
                navigationController?.setNavigationBarHidden(true, animated: animated)
            }
        }
    }
}

extension UIViewController {

    func embedInNavigationController() -> UINavigationController {
        return embedInNavigationController(navBarClass: nil)
    }

    func embedInNavigationController(navBarClass: AnyClass?) -> UINavigationController {
        let nav = BaseNavigationController(navigationBarClass: navBarClass, toolbarClass: nil)
        
        nav.viewControllers = [self]
        return nav
    }
}

public extension WaylensSpace where Base: UIViewController {

    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {

        if #available(iOS 13.0, *) {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        }

        base.present(viewControllerToPresent, animated: flag, completion: completion)
    }

}
