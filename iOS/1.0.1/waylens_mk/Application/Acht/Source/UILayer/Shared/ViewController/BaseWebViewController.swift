//
//  BaseWebViewController.swift
//  Acht
//
//  Created by Chester Shen on 10/23/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WebKit
import WaylensFoundation

class BaseWebViewController: BaseViewController {
    var webview: WKWebView!
    var url: URL?
    var signBoard: HNSignBoard?
//    var titleText: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        createWebview()
        view.addSubview(webview)
        webview.frame = view.bounds
        webview.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        webview.navigationDelegate = self
        loadURL()
        if navigationController?.viewControllers[0] === self {
            let leftButton: UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "navbar_close"), style: .plain, target: self, action: #selector(self.close))
            navigationItem.leftBarButtonItem = leftButton
        }
        // Do any additional setup after loading the view.
    }
    
    @objc override func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func createWebview() {
        webview = WKWebView()
    }

    func loadURL() {
        guard let url = url else { return }
        webview.load(URLRequest(url: url))
    }

    func refreshSignBoard() {
        if webview.isLoading {
            if signBoard == nil {
                signBoard = HNSignBoard(frame: view.bounds)
                view.addSubview(signBoard!)
                signBoard?.autoresizingMask = [.flexibleWidth , .flexibleHeight]
            }
            signBoard?.startLoading()
        } else {
            signBoard?.stopLoading()
            signBoard?.hide()
        }
    }
}

//extension BaseViewController: UIWebViewDelegate {
//    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        return navigationType != .linkClicked
//    }
//}

extension BaseWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshSignBoard()
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
