//
//  SignInContainerViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/18/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK

class AccountPageViewController: UIViewController {
    weak var container: SignInContainerViewController?
}



extension UITextFieldDelegate {
    func setupInputField(_ inputField: HNInputField, validate: Bool = false) {
        inputField.tintColor = UIColor.semanticColor(.tint(.primary)).withAlphaComponent(0.5)
        inputField.bottomLineColor = UIColor.semanticColor(.separator(.opaque))
        if validate {
            inputField.validColor = UIColor.semanticColor(.background(.quinary)).withAlphaComponent(0.7)
            inputField.inValidColor = UIColor.semanticColor(.label(.tertiary)).withAlphaComponent(0.7)
        }
        inputField.delegate = self
    }
}

class SignInContainerViewController: BaseViewController {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var imageSizeRatio: NSLayoutConstraint!
    @IBOutlet weak var imageBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var imageCenterOffset: NSLayoutConstraint!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
//    @IBAction func skipBtn(_ sender: Any) {
//        appDelegate.rootTabBarController()
//    }
    
    var logo = UIImageView()
    var contentView = UIView()
    var stacks = [AccountPageViewController]()
    
    var topVC: AccountPageViewController? {
        return stacks.last
    }
    
    var isKeyboardShown: Bool = false
    var resendTimer: WLTimer?
    var recentForgotTime: Date?
    var notRefresh: Bool = false
    let bottomMargin: CGFloat = 40
    func didForgot() {
        recentForgotTime = Date()
    }
    
    static func createViewController() -> SignInContainerViewController {
        let vc = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "SignInContainerViewController")
        return vc as! SignInContainerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(singleTap)
        
        logo.image = #imageLiteral(resourceName: "img_logo")
        logo.contentMode = .center
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        scrollview.superview?.insertSubview(logo, belowSubview: scrollview)
        scrollview.addSubview(contentView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if notRefresh {
            notRefresh = false
        } else {
            refreshUI(animated: animated)
        }
    }

    override func applyTheme() {
        super.applyTheme()

        contentView.backgroundColor = UIColor.semanticColor(.background(.primary))
    }
    
    func refreshUI(animated: Bool = false) {
        #if FLEET
        if AccountControlManager.shared.isLogin {
            quit(animated: animated, completion: nil)
        } else {
            let vc = LoginViewController.createViewController()
            vc.emailText = UserSetting.shared.lastEmail
            setRoot(vc, animated: animated)
        }
        #else
        if let lastEmail = UserSetting.shared.lastEmail {
            // did log in before
            if AccountControlManager.shared.isLogin {
                // logged in
                if AccountControlManager.shared.isVerified {
                    // verifed
                    quit(animated: animated, completion: nil)
                } else {
                    // not verified, go to verfication
                    let vc = SignUpVerifyViewController.createViewController()
                    setRoot(vc, animated: animated)
                }
            } else {
                // not logged in, go to login
                let vc = LoginViewController.createViewController()
                vc.emailText = lastEmail
                setRoot(vc, animated: animated)
            }
        } else {
            // not logged in before, sign up
            let vc = SignUpViewController.createViewController()
            setRoot(vc, animated: animated)
        }
        #endif
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        isKeyboardShown = true
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        guard let vc = topVC else { return }
        let userInfo = notification.userInfo!
        var keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        keyboardFrame = view.convert(keyboardFrame, from: nil)
//        scrollview.contentInset.bottom = keyboardFrame.size.height
        bottomSpace.constant = keyboardFrame.height
        //adjustScrollviewTopInset(contentHeight: vc.view.bounds.height)
        let value = 230 - 0.5 * keyboardFrame.height
        print("value constant keyboard",value)
        imageBottomSpace.constant = value
        view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        isKeyboardShown = false
        guard let vc = topVC else { return }
//        scrollview.contentInset = .zero
        bottomSpace.constant = 0
        adjustScrollviewTopInset(contentHeight: vc.view.bounds.height)
        imageBottomSpace.constant = 230
        view.layoutIfNeeded()
    }
    
    private func adjustScrollviewTopInset(contentHeight: CGFloat) {
        if isKeyboardShown {
            var topSpace:CGFloat = 44
            if #available(iOS 11.0, *) {
                topSpace += view.safeAreaInsets.top
            } else {
                topSpace += 20
            }
            scrollview.contentInset.top = max(view.bounds.height - bottomSpace.constant - contentHeight, topSpace)
        } else {
            var topInset = view.bounds.height - contentHeight - bottomMargin
            if #available(iOS 11, *) {
                topInset -= view.safeAreaInsets.bottom
            }
            scrollview.contentInset.top = max(topInset, 0)
            logo.frame = CGRect(x: 26, y: scrollview.contentInset.top - 50, width: 50, height: 30)
        }
    }
    
    func setRoot(_ vc: AccountPageViewController, animated:Bool=true) {
        if self.stacks.count == 1 && type(of: self.stacks[0]) === type(of: vc) {
            return
        }
        let oldVC = topVC
        self.stacks.removeAll()
        self.stacks.append(vc)
        present(vc)
        if animated {
            vc.view.alpha = 0
            if let oldVC = oldVC {
//                oldVC.beginAppearanceTransition(false, animated: true)
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                    oldVC.view.alpha = 0
                }, completion: { (completed) in
//                    oldVC.endAppearanceTransition()
                    self.remove(oldVC)
                })
            }
            let hideFirst = oldVC != nil
            
            UIView.animate(withDuration: 0.5, delay: (hideFirst ? 0.4 : 0), options: .curveEaseInOut, animations: {
                vc.view.alpha = 1
            }) { (completed) in
            }
        } else {
            remove(oldVC)
        }
    }
    
    func push(_ vc: AccountPageViewController, animated:Bool=true) {
        let oldVC = topVC
        stacks.append(vc)
        present(vc)
        if animated {
            vc.view.transform = CGAffineTransform(translationX: contentView.bounds.width, y: 0)
            //        view.layoutIfNeeded()
//            oldVC?.beginAppearanceTransition(false, animated: true)
//            vc.beginAppearanceTransition(true, animated: true)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                vc.view.transform = CGAffineTransform(translationX: 0, y: 0)
                oldVC?.view.transform = CGAffineTransform(translationX: -self.contentView.bounds.width, y: 0)
            }) { (completed) in
//                oldVC?.endAppearanceTransition()
                self.remove(oldVC)
//                vc.endAppearanceTransition()
            }
        } else {
            remove(oldVC)
        }
        updateImagePosition()
    }
    
    func pop(animated:Bool=true) {
        guard let vc = stacks.popLast() else { return }
        if let lowerVC = topVC {
            present(lowerVC)
            if animated {
                lowerVC.view.transform = CGAffineTransform(translationX: -contentView.bounds.width, y: 0)
//                lowerVC.beginAppearanceTransition(true, animated: true)
//                vc.beginAppearanceTransition(false, animated: true)
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    lowerVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
                    vc.view.transform = CGAffineTransform(translationX: self.contentView.bounds.width, y: 0)
                }) { (completed) in
//                    lowerVC.endAppearanceTransition()
//                    vc.endAppearanceTransition()
                    self.remove(vc)
                }
            } else {
                remove(vc)
            }
        } else {
            refreshUI(animated:animated)
        }
        updateImagePosition()
    }
    
    private func present(_ vc: AccountPageViewController) {
        vc.container = self
        vc.view.transform = CGAffineTransform.identity
        let size = vc.view.systemLayoutSizeFitting(CGSize(width: view.bounds.size.width, height: 0), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.fittingSizeLevel)
        vc.view.frame = CGRect(origin: .zero, size: size)
        adjustScrollviewTopInset(contentHeight: size.height)
        scrollview.contentSize = CGSize(width: size.width, height: size.height + 1)
        contentView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height + bottomMargin)
        contentView.addSubview(vc.view)
        addChild(vc)
        vc.didMove(toParent: self)
        vc.view.autoresizingMask = []
        view.layoutIfNeeded()
    }
    
    @available(iOS 11, *)
    override func viewSafeAreaInsetsDidChange() {
        if let h = topVC?.view.bounds.height {
            adjustScrollviewTopInset(contentHeight: h)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        quit(animated: true, completion: nil)
    }
    
    private func remove(_ vc: AccountPageViewController?) {
        vc?.view.removeFromSuperview()
        vc?.removeFromParent()
    }
    
    @objc func quit(animated: Bool, completion: (() -> Void)?) {
        view.resignFirstResponder()
        if let _ = presentingViewController {
//            if let nc = vc as? UINavigationController {
//                nc.popViewController(animated: false)
//                nc.viewControllers[0].closeLeft(animated: false)
//            }
            dismiss(animated: animated, completion: completion)
        } else {
            if let rootWindow = appDelegate.window {
                let rootViewController = AppViewControllerManager.createTabBarController()
                rootWindow.rootViewController = rootViewController

                UIView.transition(with: rootWindow, duration: Constants.Animation.defaultDuration, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                    rootWindow.rootViewController = rootViewController
                }, completion: { (_) in
                    completion?()
                })
            }
        }
    }
    
    private func updateImagePosition() {
        imageCenterOffset.constant = CGFloat(stacks.count - 1) * 20
        imageSizeRatio.constant = CGFloat(stacks.count - 1) * 10
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc func onTap(_ sender: UITapGestureRecognizer) {
//        let point = sender.location(in: scrollview)
//        if point.y < 0 {
            topVC?.view.endEditing(true)
//        }
    }

    @IBAction func showDebugOption(_ sender: UITapGestureRecognizer) {
        let current = UserSetting.shared.server
        let servers = AppConfig.Server.allCases
        let alert = UIAlertController(title: "Switch Server", message: nil, preferredStyle: .actionSheetOrAlertOnPad)
        for server in servers {
            alert.addAction(UIAlertAction(title: (server==current ? "current:" : "")+server.displayName, style: .default, handler: { (_) in
                if AccountControlManager.shared.isLogin, server != current {
                    WaylensClientS.shared.logout(completion: nil)
                }
                UserSetting.shared.server = server
                WLFirmwareUpgradeManager.shared().server = UserSetting.shared.server.rawValue
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
