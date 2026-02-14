//
//  WhisperMessage.swift
//  Acht
//
//  Created by Chester Shen on 8/9/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import Whisper
import SwiftMessages
import WaylensAPNGKit
import SVProgressHUD

enum HNMessageType {
    case success
    case info
    case error
    case loading
}

class HNMessage {
    static let minimumDismissTimeInterval: TimeInterval = 2.0

    static func loadStyle() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setHapticsEnabled(true)
        SVProgressHUD.setMinimumDismissTimeInterval(minimumDismissTimeInterval)
    }
    
    static func showError(message: String, to: UINavigationController?=nil) {
        
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.showError(withStatus: message)
        
//        KRProgressHUD.showError(withMessage: message)
//        HNMessage.show(type: .error, message: message, to: to)
    }
    
    static func showSuccess(message: String, to: UINavigationController?=nil) {
        
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.showSuccess(withStatus: message)
        
//        KRProgressHUD.showSuccess(withMessage: message)
//        HNMessage.show(type: .success, message: message, to: to)
    }
    
    static func showInfo(message: String, to: UINavigationController?=nil) {
        
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.showInfo(withStatus: message)
//        KRProgressHUD.showInfo(withMessage: message)
//        HNMessage.show(type: .info, message: message, to: to)
    }
    
    static func showProgress(_ progress: Float, message:String?) {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.showProgress(progress, status: message)
    }
    
    static func showIcon(_ icon: UIImage, message: String) {
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.show(icon, status: message)
    }

    static func showNotAutoDismissIcon(_ icon: UIImage, message: String) {
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setMinimumDismissTimeInterval(TimeInterval(MAXFLOAT))
        SVProgressHUD.show(icon, status: message)
        SVProgressHUD.setMinimumDismissTimeInterval(minimumDismissTimeInterval)
    }
    
    static func hideWhisper() {
        SwiftMessages.hideAll()
    }
    
    static func showWhisper(type: HNMessageType, message: String, in viewController: UIViewController?=nil) {
        let view: AlertMessageView = try! SwiftMessages.viewFromNib()
        var config = SwiftMessages.Config.init()
        config.ignoreDuplicates = true
        if let vc = viewController {
            config.presentationContext = .viewController(vc)
        }
        switch type {
        case .error:
            
            view.setup(icon: UIImage(named: "camera setting_notice_error"), message: message, backgroundColor: UIColor.semanticColor(.background(.tertiary)))
            config.duration = .seconds(seconds: 6)
            config.interactiveHide = true
        case .loading:
            view.setup(loading: true, message: message, backgroundColor: UIColor.semanticColor(.tint(.primary)))
            config.duration = .forever
            config.interactiveHide = false
            break
        case .success:
            view.setup(icon: UIImage(named: "camera setting_notice_finish"), message: message, backgroundColor: UIColor.semanticColor(.background(.quinary)))
            config.duration = .automatic
            config.interactiveHide = true
        default:
            break
        }
        
        if let current = SwiftMessages.sharedInstance.current() as? AlertMessageView {
            if current.id == view.id {
                return
            } else {
                SwiftMessages.hideAll()
            }
        }
        SwiftMessages.show(config: config, view: view)
    }

    static func showWhisper(for message: HNCameraMessage, in viewController: UIViewController? = nil, completion: @escaping (HNCameraMessage) -> ()) {
        guard !message.content.isEmpty else {
            return
        }

        let view: CameraMessageView = try! SwiftMessages.viewFromNib()
        view.closeButtonTapHandler = { _ in
            completion(message)
            SwiftMessages.hide(id: view.id)
        }
        view.buttonTapHandler = { _ in
            completion(message)
            SwiftMessages.hide(id: view.id)
            message.actionBlock?()
        }

        var config = SwiftMessages.Config.init()
        config.ignoreDuplicates = true

        if let vc = viewController {
            config.presentationContext = .viewController(vc)
        }

        view.config(with: message)

        config.duration = .forever
        config.interactiveHide = false

        if let current = SwiftMessages.sharedInstance.current() as? AlertMessageView {
            if current.id == view.id {
                return
            } else {
                SwiftMessages.hideAll()
            }
        }
        SwiftMessages.show(config: config, view: view)
    }

    static func show(message: String?=nil) {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: message)
//        KRProgressHUD.show()
    }
    
    static func dismiss() {
        SVProgressHUD.dismiss()
//        KRProgressHUD.dismiss()
    }

    static func dismiss(withDelay delay: TimeInterval, completion: SVProgressHUDDismissCompletion? = nil) {
        SVProgressHUD.dismiss(withDelay: delay, completion: completion)
    }

    static func isVisible() -> Bool {
        return SVProgressHUD.isVisible()
    }
}
