//
//  TypeAlias.swift
//  NFCPassportReaderApp
//
//  Created by TranHoangThanh on 4/29/21.
//  Copyright © 2021 Andy Qua. All rights reserved.
//

import UIKit


typealias SUCCESS_CLORUSE = (() -> ())
typealias ERROR_CLORUSE = ((Error?) -> ())


// iOS13 or later
//if #available(iOS 13.0, *) {
//    let sceneDelegate = UIApplication.shared.connectedScenes
//        .first!.delegate as! SceneDelegate
//
//
//// iOS12 or earlier
//} else {
//    // UIApplication.shared.keyWindow?.rootViewController
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//}

var notification : NotificationCenter {
    return NotificationCenter.default
}

var appDelegate : AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

//var sceneDelegate :  SceneDelegate {
//    return UIApplication.shared.connectedScenes
//        .first!.delegate as! SceneDelegate
//}

var window: UIWindow? {
    if #available(iOS 13, *) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let delegate = windowScene.delegate as? AppDelegate, let window = delegate.window else { return nil }
               return window
    }
//    
    guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
    return window
}

func rootToVC(_ vc: UIViewController) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    if #available(iOS 13.0, *){
        if let scene = UIApplication.shared.connectedScenes.first {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            print(">>> windowScene: \(windowScene)")
            let window: UIWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
            window.windowScene = windowScene //Make sure to do this
            window.rootViewController = vc
            window.makeKeyAndVisible()
            appDelegate.window = window
        }
    } else {
        appDelegate.window?.rootViewController = vc
        appDelegate.window?.makeKeyAndVisible()
    }
}
