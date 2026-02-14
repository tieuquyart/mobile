//
//  PlanWebViewController.swift
//  Acht
//
//  Created by Chester Shen on 7/18/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WebKit
import WaylensFoundation

class PlanWebViewController: BaseViewController, CameraRelated {
    var webview: WKWebView!
    var signBoard: HNSignBoard?
    var camera: UnifiedCamera?
    @IBOutlet weak var backButton: UIButton!
    
    static func createViewController() -> PlanWebViewController {
        let vc = UIStoryboard(name: "CameraSettings", bundle: nil).instantiateViewController(withIdentifier: "PlanWebViewController")
        return vc as! PlanWebViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "\(UserSetting.shared.webServer.rawValue)/my/device/\(camera?.sn ?? "")/4g_subscription")
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        let userContent = WKUserContentController()
        let userScript = WKUserScript(source: "document.cookie = 'user-token=\(AccountControlManager.shared.keyChainMgr.token!)'; var _console = console; var console = {}; console.log = function() { var message = Array.from(arguments).map(JSON.stringify).join(' '); _console.log(message); window.webkit.messageHandlers['logger'].postMessage(message)}; console.debug = console.log; console.info = console.log; console.warn = console.log; console.error = console.log; console.log('user agent:', navigator.userAgent)", injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContent.addUserScript(userScript)
        userContent.add(self, name: "logger")
        let webviewConfig = WKWebViewConfiguration()
        webviewConfig.userContentController = userContent
        webviewConfig.applicationNameForUserAgent = "\(webviewConfig.applicationNameForUserAgent ?? "") Secure360 app webview"
        webview = WKWebView(frame: view.bounds, configuration: webviewConfig)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.alpha = 0
        view.insertSubview(webview, at: 0)
        webview.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        webview.load(request)
    }
    
    func refreshSignBoard() {
        if webview.isLoading {
            if signBoard == nil {
                signBoard = HNSignBoard(frame: view.bounds)
                view.insertSubview(signBoard!, belowSubview: backButton)
                signBoard?.autoresizingMask = [.flexibleWidth , .flexibleHeight]
            }
            signBoard?.startLoading()
        } else {
            signBoard?.stopLoading()
            signBoard?.hide()
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PlanWebViewController: WKUIDelegate {
    func webViewDidClose(_ webView: WKWebView) {
        dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel) { (_) in
            completionHandler()
        })
        present(alert, animated: true, completion: nil)
    }
}

extension PlanWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshSignBoard()
//        backButton.isHidden = true
        UIView.animate(withDuration: 0.3) {
            webView.alpha = 1
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        refreshSignBoard()
        webView.alpha = 0
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Log.error("Failed to load plan web")
        signBoard?.showDisconnected()
    }
}

extension PlanWebViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        let body = message.body as! String
        if message.name == "logger" {
            print("JS log:\(body)")
            return
        } else if message.name == "waylens" {
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
//class PlanWebViewController: BaseViewController, CameraRelated {
//    var webview: UIWebView!
//    var camera: UnifiedCamera?
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let url = URL(string: "http://beta.waylens.com/my/device/\(camera?.sn ?? "")/4g_subscription")
//        let request = URLRequest(url: url!)
//
//        webview = UIWebView(frame: view.bounds)
//        view.addSubview(webview)
//        webview.autoresizingMask = [.flexibleWidth , .flexibleHeight]
//        let userAgent = webview.stringByEvaluatingJavaScript(from: "navigator.userAgent")! + " webview"
//        let cookie = HTTPCookie(properties: [
//            .name : "user-token",
//            .value: AccountControlManager.shared.keyChainMgr.token!,
//            .domain: "waylens.com",
//            .path: "/"
//        ])
//        HTTPCookieStorage.shared.setCookie(cookie!)
//        webview.loadRequest(request)
//    }
//}
