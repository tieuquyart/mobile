//
//  FXOChatViewController.swift
//  Acht
//
//  Created by Chester Shen on 1/10/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import Foundation
import WebKit

class FXOChatViewController: BaseWebViewController {
    
    override func createWebview() {
        let userContent = WKUserContentController()
        let username = AccountControlManager.shared.keyChainMgr.userName!
        let email = AccountControlManager.shared.keyChainMgr.email!
        let userScript = WKUserScript(source: "setMetadata('Secure360','\(username)','\(email)');", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContent.addUserScript(userScript)
        userContent.add(self, name: "waylens")
        let webviewConfig = WKWebViewConfiguration()
        webviewConfig.userContentController = userContent
        webviewConfig.applicationNameForUserAgent = "\(webviewConfig.applicationNameForUserAgent ?? "") Secure360 app webview"
        webview = WKWebView(frame: view.bounds, configuration: webviewConfig)
    }
    
    override func loadURL() {
        url = Bundle.main.url(forResource: "chat", withExtension: "html")
        super.loadURL()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Contact Support", comment: "Contact Support")
    }
}

extension FXOChatViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body as? String
        if message.name == "waylens" {
            if body == "close" {
                if presentingViewController == nil {
                    navigationController?.popViewController(animated: true)
                } else {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
